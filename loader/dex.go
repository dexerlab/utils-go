package loader

import (
	"context"
	"errors"
	"fmt"
	"strings"
	"sync"

	"github.com/dexerlab/utils-go/alert"
	"github.com/dexerlab/utils-go/dal/model"
	"github.com/dexerlab/utils-go/dal/query"
	"github.com/dexerlab/utils-go/util"
	"github.com/dgraph-io/ristretto/v2"
	"github.com/shopspring/decimal"
	"gorm.io/gorm"
)

type AddrType int

const (
	AddrTypeUnknown AddrType = iota
	AddrTypeToken            // 1
	AddrTypePool             // 2
)

type TokenDyn struct {
	id           int64
	decimal      int32
	priceu       float64
	bestPoolId   int64
	bestPoolVliq float64
}

type PoolDyn struct {
	id         int64
	liquidity0 decimal.Decimal
	liquidity1 decimal.Decimal
	liquidityu float64
	block      int64
}

// factory: 0x1..|0x2...|0x3...
type DexManager struct {
	chainFamousTokens map[string]map[string]*model.TFamousToken // chainname -> address -> famous token
	idDexs            map[int64]*model.TDex
	idDexPools        map[int64]*model.TDexPool
	idLaunchpads      map[int64]*model.TLaunchpad
	factoryDexPools   map[string]*model.TDexPool
	factoryLaunchpads map[string]*model.TLaunchpad
	tokenDyns         *ristretto.Cache[int64, TokenDyn] // address_chainid -> tokendyn
	addrIds           *ristretto.Cache[string, int64]   // address_chainid -> tokenid
	poolDyns          *ristretto.Cache[int64, PoolDyn]  // address_chainid -> tokendyn
	alerter           alert.Alerter

	mutex *sync.RWMutex
}

func NewDexManager(alerter alert.Alerter) *DexManager {

	tokenDyns, err := ristretto.NewCache(&ristretto.Config[int64, TokenDyn]{
		NumCounters: 1e8, // number of keys to track frequency of (10M).
		MaxCost:     1e7,
		BufferItems: 64, // number of keys per Get buffer.
	})
	if err != nil {
		panic(err)
	}

	poolDyns, err := ristretto.NewCache(&ristretto.Config[int64, PoolDyn]{
		NumCounters: 1e8, // number of keys to track frequency of (10M).
		MaxCost:     1e7, // maximum cost of cache (1GB).
		BufferItems: 64,  // number of keys per Get buffer.
	})
	if err != nil {
		panic(err)
	}

	addrIds, err := ristretto.NewCache(&ristretto.Config[string, int64]{
		NumCounters: 1e8, // number of keys to track frequency of (10M).
		MaxCost:     1e7,
		BufferItems: 64, // number of keys per Get buffer.
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
		addrIds:           addrIds,
		poolDyns:          poolDyns,
		alerter:           alerter,
		mutex:             &sync.RWMutex{},
	}
}

func (mgr *DexManager) SetIdByAddress(chainid int64, address string, id int64, addrType AddrType) {
	keyAddr := util.NormalizeAddress(address)
	key := fmt.Sprintf("%s|%d", keyAddr, chainid)
	mgr.addrIds.Set(key, id, 1)
	//mgr.addrIds.Wait()
}

func (mgr *DexManager) GetIdByAddress(chainid int64, address string, addrType AddrType, cache bool, cache404 bool) (int64, bool) {
	keyAddr := util.NormalizeAddress(address)
	key := fmt.Sprintf("%s|%d", keyAddr, chainid)

	if cache {
		if v, ok := mgr.addrIds.Get(key); ok {
			if v <= 0 {
				return 0, false
			} else {
				return v, true
			}
		}
	}
	// not found in cache; load from DB via query
	var id int64
	var err error
	switch addrType {
	case AddrTypeToken:
		s := query.TTokenDynamic
		var tkn *model.TTokenDynamic
		tkn, err = s.WithContext(context.Background()).
			Select(s.ID).
			Where(s.Address.Eq(keyAddr), s.ChainID.Eq(chainid)).First()
		if err == nil {
			id = tkn.ID
		}
	case AddrTypePool:
		s := query.TPoolDynamic
		var pool *model.TPoolDynamic
		pool, err = s.WithContext(context.Background()).
			Select(s.ID).
			Where(s.Address.Eq(keyAddr), s.ChainID.Eq(chainid)).First()
		if err == nil {
			id = pool.ID
		}
	default:
		return 0, false
	}

	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			if cache && cache404 {
				mgr.addrIds.Set(key, -1, 1)
			}
		} else {
			mgr.alerter.AlertText("DexManager.GetIdByAddress: query token failed", err)
		}
		return 0, false
	}

	if cache {
		mgr.addrIds.Set(key, id, 1)
		//mgr.addrIds.Wait()
	}

	return id, true
}

func (mgr *DexManager) SetPoolDynCache(id int64, dyn PoolDyn) {
	mgr.poolDyns.Set(id, dyn, 1)
	//mgr.poolDyns.Wait()
}

func (mgr *DexManager) GetPoolDyn(chainid int64, address string, cache bool, cache404 bool) (PoolDyn, bool) {

	id, ok := mgr.GetIdByAddress(chainid, address, AddrTypePool, cache, cache404)
	if !ok {
		return PoolDyn{}, false
	}

	if cache {
		if v, ok := mgr.poolDyns.Get(id); ok {
			if v.id <= 0 {
				return PoolDyn{}, false
			} else {
				return v, true
			}
		}
	}
	keyAddr := util.NormalizeAddress(address)
	// not found in cache; load from DB via query
	pn, err := query.TPoolDynamic.WithContext(context.Background()).Where(query.TPoolDynamic.Address.Eq(keyAddr), query.TPoolDynamic.ChainID.Eq(chainid)).First()
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			if cache && cache404 {
				dyn := PoolDyn{id: -1}
				mgr.poolDyns.Set(id, dyn, 1)
			}
		} else {
			mgr.alerter.AlertText("DexManager.GetTokenDyn: query token failed", err)
		}
		return PoolDyn{}, false
	}

	dyn := PoolDyn{liquidity0: pn.Liquidity0, liquidity1: pn.Liquidity1, liquidityu: pn.Liquidityu, id: pn.ID, block: pn.Block}

	if cache {
		mgr.poolDyns.Set(id, dyn, 1)
		//mgr.poolDyns.Wait()
	}
	return dyn, true
}

func (mgr *DexManager) GetTokenPriceu(chainid int64, chainName string, address string, cache bool, cache404 bool) (float64, bool) {
	ftkn, ok := mgr.GetFamousToken(chainName, address)
	if ok && ftkn.IsStable {
		return 1.0, true
	}

	tknDyn, ok := mgr.GetTokenDyn(chainid, address, cache, cache404)
	if !ok {
		return 0, false
	}
	return tknDyn.priceu, true
}

func (mgr *DexManager) SetTokenDynCache(id int64, dyn TokenDyn) {
	mgr.tokenDyns.Set(id, dyn, 1)
	//mgr.tokenDyns.Wait()
}

func (mgr *DexManager) GetTokenDyn(chainid int64, address string, cache bool, cache404 bool) (TokenDyn, bool) {

	id, ok := mgr.GetIdByAddress(chainid, address, AddrTypeToken, cache, cache404)
	if !ok {
		return TokenDyn{}, false
	}

	if cache {
		if v, ok := mgr.tokenDyns.Get(id); ok {
			if v.id <= 0 {
				return TokenDyn{}, false
			} else {
				return v, true
			}
		}
	}

	d := query.TTokenDynamic
	s := query.TTokenStatic
	keyAddr := util.NormalizeAddress(address)
	// not found in cache; load from DB via query
	tkn, err := d.WithContext(context.Background()).
		Select(d.ALL, s.Decimals).
		LeftJoin(s, s.TokenID.EqCol(d.ID)).
		Where(d.Address.Eq(keyAddr), d.ChainID.Eq(chainid)).First()

	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			if cache && cache404 {
				dyn := TokenDyn{id: -1}
				mgr.tokenDyns.Set(id, dyn, 1)
			}
		} else {
			mgr.alerter.AlertText("DexManager.GetTokenDyn: query token failed", err)
		}
		return TokenDyn{}, false
	}

	dyn := TokenDyn{priceu: tkn.Priceu, id: tkn.ID}
	if cache {
		mgr.tokenDyns.Set(id, dyn, 1)
		//mgr.tokenDyns.Wait()
	}

	return dyn, true
}

func (mgr *DexManager) DbUpdatePoolLiqBatch(chainid int64, addrLiq0 map[string]decimal.Decimal, addrLiq1 map[string]decimal.Decimal,
	addrLiqu map[string]float64, block int64) {

	updates := make([]*model.TPoolDynamic, 0, len(addrLiq0))
	for addr := range addrLiq0 {
		keyAddr := util.NormalizeAddress(addr)
		liq0, ok0 := addrLiq0[addr]
		liq1, ok1 := addrLiq1[addr]
		liqu, oku := addrLiqu[addr]
		if !ok0 || !ok1 || !oku {
			continue
		}
		pool := &model.TPoolDynamic{
			Address:    keyAddr,
			ChainID:    chainid,
			Liquidity0: liq0,
			Liquidity1: liq1,
			Liquidityu: liqu,
			Block:      block,
		}
		updates = append(updates, pool)
	}

	if err := query.TPoolDynamic.WithContext(context.Background()).Save(updates...); err != nil {
		mgr.alerter.AlertText("DexManager.UpdateDBPoolLiqBatch: save pool liquidity batch failed", err)
	}
}

func (mgr *DexManager) DbUpdateTokenPriceuBatch(chainid int64, addrPriceu map[string]float64) {

	updates := make([]*model.TTokenDynamic, 0, len(addrPriceu))
	for addr, priceu := range addrPriceu {
		keyAddr := util.NormalizeAddress(addr)
		tkn := &model.TTokenDynamic{
			Address: keyAddr,
			ChainID: chainid,
			Priceu:  priceu,
		}
		updates = append(updates, tkn)
	}

	if err := query.TTokenDynamic.WithContext(context.Background()).Save(updates...); err != nil {
		mgr.alerter.AlertText("DexManager.UpdateDBTokenPriceuBatch: save token priceu batch failed", err)
	}
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

func (mgr *DexManager) IsFamousStable(chainName, address string) bool {
	ft, ok := mgr.GetFamousToken(chainName, address)
	return ok && ft.IsStable
}

func (mgr *DexManager) IsFamousNative(chainName, address string) bool {
	ft, ok := mgr.GetFamousToken(chainName, address)
	return ok && ft.IsNative
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
