package loader

import (
	"context"
	"fmt"
	"strings"
	"sync"

	"github.com/dexerlab/utils-go/alert"
	"github.com/dexerlab/utils-go/dal/model"
	"github.com/dexerlab/utils-go/dal/query"
	"github.com/dexerlab/utils-go/util"
	"github.com/dgraph-io/ristretto/v2"
	"github.com/shopspring/decimal"
)

type TokenDyn struct {
	priceu float64
}

type PoolDyn struct {
	liquidity0 decimal.Decimal
	liquidity1 decimal.Decimal
	liquidityu float64
}

// factory: 0x1..|0x2...|0x3...
type DexManager struct {
	chainFamousTokens map[string]map[string]*model.TFamousToken // chainname -> address -> famous token
	idDexs            map[int64]*model.TDex
	idDexPools        map[int64]*model.TDexPool
	idLaunchpads      map[int64]*model.TLaunchpad
	factoryDexPools   map[string]*model.TDexPool
	factoryLaunchpads map[string]*model.TLaunchpad
	tokenDyns         *ristretto.Cache[string, TokenDyn] // address_chainid -> tokendyn
	poolDyns          *ristretto.Cache[string, PoolDyn]  // address_chainid -> tokendyn
	alerter           alert.Alerter

	mutex *sync.RWMutex
}

func NewDexManager(alerter alert.Alerter) *DexManager {

	tokenDyns, err := ristretto.NewCache(&ristretto.Config[string, TokenDyn]{
		NumCounters: 1e8, // number of keys to track frequency of (10M).
		MaxCost:     1e7,
		BufferItems: 64, // number of keys per Get buffer.
	})
	if err != nil {
		panic(err)
	}

	poolDyns, err := ristretto.NewCache(&ristretto.Config[string, PoolDyn]{
		NumCounters: 1e8, // number of keys to track frequency of (10M).
		MaxCost:     1e7, // maximum cost of cache (1GB).
		BufferItems: 64,  // number of keys per Get buffer.
	})
	if err != nil {
		panic(err)
	}

	return &DexManager{
		idDexs:            make(map[int64]*model.TDex),
		idDexPools:        make(map[int64]*model.TDexPool),
		idLaunchpads:      make(map[int64]*model.TLaunchpad),
		factoryDexPools:   make(map[string]*model.TDexPool),
		factoryLaunchpads: make(map[string]*model.TLaunchpad),
		tokenDyns:         tokenDyns,
		poolDyns:          poolDyns,
		alerter:           alerter,
		mutex:             &sync.RWMutex{},
	}
}

func (mgr *DexManager) GetPoolDyn(chainid int64, address string) (PoolDyn, bool) {

	keyAddr := util.NormalizeAddress(address)

	key := fmt.Sprintf("%s|%d", keyAddr, chainid)
	if v, ok := mgr.poolDyns.Get(key); ok {
		return v, true
	}

	// not found in cache; load from DB via query
	pn, err := query.TPool.WithContext(context.Background()).Where(query.TPool.Address.Eq(keyAddr), query.TPool.ChainID.Eq(chainid)).First()
	if err != nil {
		return PoolDyn{}, false
	}

	dyn := PoolDyn{liquidity0: pn.Liquidity0, liquidity1: pn.Liquidity1, liquidityu: pn.Liquidityu}
	mgr.poolDyns.Set(key, dyn, 1)
	//mgr.poolDyns.Wait()

	return dyn, true
}

func (mgr *DexManager) GetTokenPriceu(chainid int64, address string) (float64, bool) {
	tknDyn, ok := mgr.GetTokenDyn(chainid, address)
	if !ok {
		return 0, false
	}
	return tknDyn.priceu, true
}

func (mgr *DexManager) SetTokenDyn(chainid int64, address string, dyn TokenDyn) {
	keyAddr := util.NormalizeAddress(address)
	key := fmt.Sprintf("%s|%d", keyAddr, chainid)
	mgr.tokenDyns.Set(key, dyn, 1)
	//mgr.tokenDyns.Wait()
}

func (mgr *DexManager) SetTokenPriceu(chainid int64, address string, priceu float64) {
	keyAddr := util.NormalizeAddress(address)
	key := fmt.Sprintf("%s|%d", keyAddr, chainid)
	dyn := TokenDyn{priceu: priceu}
	mgr.tokenDyns.Set(key, dyn, 1)
	//mgr.tokenDyns.Wait()
}

func (mgr *DexManager) UpdateTokenPriceuBatch(chainid int64, addrPriceu map[string]float64) {

	updates := make([]*model.TToken, 0, len(addrPriceu))
	for addr, priceu := range addrPriceu {
		keyAddr := util.NormalizeAddress(addr)
		tkn := &model.TToken{
			ChainID: chainid,
			Address: keyAddr,
			Priceu:  priceu,
		}
		updates = append(updates, tkn)
	}

	if err := query.TToken.WithContext(context.Background()).SaveAll(updates); err != nil {
		mgr.alerter.AlertText("DexManager.UpdateDBTokenPriceuBatch: save token priceu batch failed", err)
	}
}

func (mgr *DexManager) GetTokenDyn(chainid int64, address string) (TokenDyn, bool) {

	keyAddr := util.NormalizeAddress(address)

	key := fmt.Sprintf("%s|%d", keyAddr, chainid)
	if v, ok := mgr.tokenDyns.Get(key); ok {
		return v, true
	}

	// not found in cache; load from DB via query
	tkn, err := query.TToken.WithContext(context.Background()).Where(query.TToken.Address.Eq(keyAddr), query.TToken.ChainID.Eq(chainid)).First()
	if err != nil {
		return TokenDyn{}, false
	}

	dyn := TokenDyn{priceu: tkn.Priceu}
	mgr.tokenDyns.Set(key, dyn, 1)
	//mgr.tokenDyns.Wait()

	return dyn, true
}

func (mgr *DexManager) GetDexPoolByID(id int64) (*model.TDexPool, bool) {
	mgr.mutex.RLock()
	defer mgr.mutex.RUnlock()
	pool, ok := mgr.idDexPools[id]
	return pool, ok
}

func (mgr *DexManager) GetLaunchpadByID(id int64) (*model.TLaunchpad, bool) {
	mgr.mutex.RLock()
	defer mgr.mutex.RUnlock()
	lp, ok := mgr.idLaunchpads[id]
	return lp, ok
}

func (mgr *DexManager) GetDexByID(id int64) (*model.TDex, bool) {
	mgr.mutex.RLock()
	defer mgr.mutex.RUnlock()
	dex, ok := mgr.idDexs[id]
	return dex, ok
}

func (mgr *DexManager) GetAllDexIds() []int64 {
	mgr.mutex.RLock()
	defer mgr.mutex.RUnlock()
	ids := make([]int64, 0, len(mgr.idDexs))
	for id := range mgr.idDexs {
		ids = append(ids, id)
	}
	return ids
}

func (mgr *DexManager) GetAllLaunchpadIds() []int64 {
	mgr.mutex.RLock()
	defer mgr.mutex.RUnlock()
	ids := make([]int64, 0, len(mgr.idLaunchpads))
	for id := range mgr.idLaunchpads {
		ids = append(ids, id)
	}
	return ids
}

func (mgr *DexManager) GetDexByFactory(factory string) (*model.TDex, *model.TDexPool, bool) {
	mgr.mutex.RLock()
	defer mgr.mutex.RUnlock()
	key := util.NormalizeAddress(factory)
	if key == "" {
		return nil, nil, false
	}

	pool, ok := mgr.factoryDexPools[key]
	if !ok {
		return nil, nil, false
	}

	dex, ok := mgr.idDexs[int64(pool.DexID)]
	if !ok {
		return nil, pool, false
	}

	return dex, pool, true
}

func (mgr *DexManager) GetLaunchpadByFactory(factory string) (*model.TLaunchpad, bool) {
	mgr.mutex.RLock()
	defer mgr.mutex.RUnlock()
	key := util.NormalizeAddress(factory)
	if key == "" {
		return nil, false
	}
	lp, ok := mgr.factoryLaunchpads[key]
	if !ok {
		return nil, false
	}
	return lp, true
}

func (mgr *DexManager) GetFamousToken(chainName, address string) (*model.TFamousToken, bool) {
	mgr.mutex.RLock()
	defer mgr.mutex.RUnlock()
	chainKey := util.NormalizeString(chainName)
	addrKey := util.NormalizeAddress(address)
	chainMap, ok := mgr.chainFamousTokens[chainKey]
	if !ok {
		return nil, false
	}
	ft, ok := chainMap[addrKey]
	if !ok {
		return nil, false
	}
	return ft, true
}

func (mgr *DexManager) IsFamousToken(chainName, address string) bool {
	_, ok := mgr.GetFamousToken(chainName, address)
	return ok
}

func (mgr *DexManager) LoadInfo() {

	// temp maps
	idDexs := make(map[int64]*model.TDex)
	factoryDexPools := make(map[string]*model.TDexPool)
	factoryLaunchpads := make(map[string]*model.TLaunchpad)
	idDexPools := make(map[int64]*model.TDexPool)
	idLaunchpads := make(map[int64]*model.TLaunchpad)
	chainFamousToken := make(map[string]map[string]*model.TFamousToken)

	// load t_dex
	if dexList, err := query.TDex.WithContext(context.Background()).Find(); err != nil {
		mgr.alerter.AlertText("DexManager.LoadInfo: load t_dex failed", err)
	} else {
		for _, d := range dexList {
			idDexs[int64(d.ID)] = d
		}
	}

	// load t_dex_pool
	if poolList, err := query.TDexPool.WithContext(context.Background()).Find(); err != nil {
		mgr.alerter.AlertText("DexManager.LoadInfo: load t_dex_pool failed", err)
	} else {
		for _, p := range poolList {
			idDexPools[int64(p.ID)] = p
			if pFactory := strings.TrimSpace(p.Factory); pFactory != "" {
				parts := strings.Split(pFactory, "|")
				for _, part := range parts {
					key := util.NormalizeAddress(part)
					if key == "" {
						continue
					}
					factoryDexPools[key] = p
				}
			}
		}
	}

	// load t_launchpad
	if lpList, err := query.TLaunchpad.WithContext(context.Background()).Find(); err != nil {
		mgr.alerter.AlertText("DexManager.LoadInfo: load t_launchpad failed", err)
	} else {
		for _, lp := range lpList {
			idLaunchpads[int64(lp.ID)] = lp
			if lpFactory := strings.TrimSpace(lp.Factory); lpFactory != "" {
				parts := strings.Split(lpFactory, "|")
				for _, part := range parts {
					key := util.NormalizeAddress(part)
					if key == "" {
						continue
					}
					factoryLaunchpads[key] = lp
				}
			}
		}
	}

	// load t_famous_token
	if ftList, err := query.TFamousToken.WithContext(context.Background()).Find(); err != nil {
		mgr.alerter.AlertText("DexManager.LoadInfo: load t_famous_token failed", err)
	} else {
		for _, ft := range ftList {
			chainName := util.NormalizeString(ft.ChainName)
			if chainName == "" {
				continue
			}
			addr := util.NormalizeAddress(ft.TokenAddress)
			if addr == "" {
				continue
			}
			if _, ok := chainFamousToken[chainName]; !ok {
				chainFamousToken[chainName] = make(map[string]*model.TFamousToken)
			}
			chainFamousToken[chainName][addr] = ft
		}
	}

	mgr.mutex.Lock()
	mgr.chainFamousTokens = chainFamousToken
	mgr.idDexs = idDexs
	mgr.idDexPools = idDexPools
	mgr.idLaunchpads = idLaunchpads
	mgr.factoryDexPools = factoryDexPools
	mgr.factoryLaunchpads = factoryLaunchpads
	mgr.mutex.Unlock()
}
