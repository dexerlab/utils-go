package loader

import (
	"context"
	"errors"
	"fmt"
	"strings"

	"github.com/dexerlab/utils-go/alert"
	"github.com/dexerlab/utils-go/dal/model"
	"github.com/dexerlab/utils-go/dal/query"
	"github.com/dexerlab/utils-go/util"
	"github.com/dgraph-io/ristretto/v2"
	"github.com/shopspring/decimal"
	"gorm.io/gorm"
	"gorm.io/gorm/clause"
)

type AddrType int

const (
	AddrTypeUnknown AddrType = iota
	AddrTypeToken            // 1
	AddrTypePool             // 2
)

type TokenDyn struct {
	ID           int64
	Priceu       float64
	BestPoolId   int64
	BestPoolVliq float64
	Decimals     int32
}

type PoolDyn struct {
	ID         int64
	Liquidity0 decimal.Decimal
	Liquidity1 decimal.Decimal
	Liquidityu float64
	Block      int64
	Token0ID   int64
	Token1ID   int64
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
	}
}

func (mgr *DexManager) SetIdByAddress(chainid int64, address string, id int64, addrType AddrType) {
	keyAddr := util.NormalizeAddress(address)
	key := fmt.Sprintf("%s|%d", keyAddr, chainid)
	mgr.addrIds.Set(key, id, 1)
	//mgr.addrIds.Wait()
}

func (mgr *DexManager) GetIdByAddress(chainid int64, address string, addrType AddrType, cache bool, cache404 bool) (int64, bool, error) {
	keyAddr := util.NormalizeAddress(address)
	key := fmt.Sprintf("%s|%d", keyAddr, chainid)

	if cache {
		if v, ok := mgr.addrIds.Get(key); ok {
			if v <= 0 {
				return 0, false, nil
			} else {
				return v, true, nil
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
		return 0, false, nil
	}

	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			if cache && cache404 {
				mgr.addrIds.Set(key, 0, 1)
			}
			return 0, false, nil
		} else {
			mgr.alerter.AlertText("DexManager.GetIdByAddress: query token failed", err)
			return 0, false, err
		}
	}

	if cache {
		mgr.addrIds.Set(key, id, 1)
		//mgr.addrIds.Wait()
	}

	return id, true, nil
}

func (mgr *DexManager) SetPoolDynCache(id int64, dyn PoolDyn) {
	mgr.poolDyns.Set(id, dyn, 1)
	//mgr.poolDyns.Wait()
}

func (mgr *DexManager) GetPoolDyn(chainid int64, address string, cache bool, cache404 bool) (PoolDyn, bool, error) {

	var id int64 = 0
	if cache {
		aid, ok, err := mgr.GetIdByAddress(chainid, address, AddrTypePool, cache, cache404)
		if !ok || err != nil {
			return PoolDyn{}, false, err
		}
		id = aid
	}

	if cache {
		if v, ok := mgr.poolDyns.Get(id); ok {
			if v.ID <= 0 {
				return PoolDyn{}, false, nil
			} else {
				return v, true, nil
			}
		}
	}
	keyAddr := util.NormalizeAddress(address)

	d := query.TPoolDynamic
	s := query.TPoolStatic

	var dyn PoolDyn
	err := d.WithContext(context.Background()).
		Select(d.ID, d.Liquidity0, d.Liquidity1, d.Liquidityu, d.Block, s.Token0ID, s.Token1ID).
		LeftJoin(s, s.PoolID.EqCol(d.ID)).
		Where(d.Address.Eq(keyAddr), d.ChainID.Eq(chainid)).Scan(&dyn)

	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			if cache && cache404 {
				dyn := PoolDyn{ID: 0}
				mgr.poolDyns.Set(id, dyn, 1)
			}
			return PoolDyn{}, false, nil
		} else {
			mgr.alerter.AlertText("DexManager.GetTokenDyn: query token failed", err)
			return PoolDyn{}, false, err
		}

	}

	if cache {
		mgr.poolDyns.Set(id, dyn, 1)
		//mgr.poolDyns.Wait()
	}
	return dyn, true, nil
}

func (mgr *DexManager) GetTokenPriceu(chainid int64, chainName string, address string, cache bool, cache404 bool) (float64, bool, error) {
	ftkn, ok := mgr.GetFamousToken(chainName, address)
	if ok && ftkn.IsStable {
		return 1.0, true, nil
	}

	tknDyn, ok, err := mgr.GetTokenDyn(chainid, address, cache, cache404)
	if !ok || err != nil {
		return 0, false, err
	}
	return tknDyn.Priceu, true, nil
}

func (mgr *DexManager) SetTokenDynCache(id int64, dyn TokenDyn) {
	mgr.tokenDyns.Set(id, dyn, 1)
	//mgr.tokenDyns.Wait()
}

func (mgr *DexManager) GetTokenDyn(chainid int64, address string, cache bool, cache404 bool) (TokenDyn, bool, error) {

	var id int64 = 0
	if cache {
		aid, ok, err := mgr.GetIdByAddress(chainid, address, AddrTypePool, cache, cache404)
		if !ok || err != nil {
			return TokenDyn{}, false, err
		}
		id = aid
	}

	if cache {
		if v, ok := mgr.tokenDyns.Get(id); ok {
			if v.ID <= 0 {
				return TokenDyn{}, false, nil
			} else {
				return v, true, nil
			}
		}
	}

	d := query.TTokenDynamic
	s := query.TTokenStatic
	keyAddr := util.NormalizeAddress(address)
	// not found in cache; load from DB via query
	var dyn TokenDyn
	err := d.WithContext(context.Background()).
		Select(d.ID, d.Priceu, d.BestPoolID, d.BestPoolVliq, s.Decimals).
		LeftJoin(s, s.TokenID.EqCol(d.ID)).
		Where(d.Address.Eq(keyAddr), d.ChainID.Eq(chainid)).Scan(&dyn)

	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			if cache && cache404 {
				dyn := TokenDyn{ID: 0}
				mgr.tokenDyns.Set(id, dyn, 1)
			}
			return TokenDyn{}, false, nil
		} else {
			mgr.alerter.AlertText("DexManager.GetTokenDyn: query token failed", err)
			return TokenDyn{}, false, err
		}

	}

	if cache {
		mgr.tokenDyns.Set(id, dyn, 1)
		//mgr.tokenDyns.Wait()
	}

	return dyn, true, nil
}

func (mgr *DexManager) DbUpdatePoolDynBatch(chainid int64, ids []int64, liq0s []decimal.Decimal, liq1s []decimal.Decimal,
	liqus []float64, block int64) error {

	if len(ids) != len(liq0s) || len(ids) != len(liq1s) || len(ids) != len(liqus) {
		return errors.New("DexManager.DbUpdatePoolDynBatch: input slices length mismatch")
	}

	updates := make([]*model.TPoolDynamic, 0, len(ids))
	for i, id := range ids {
		pool := &model.TPoolDynamic{
			ID:         id,
			Liquidity0: liq0s[i],
			Liquidity1: liq1s[i],
			Liquidityu: liqus[i],
			Block:      block,
		}
		updates = append(updates, pool)
	}

	err := query.TPoolDynamic.WithContext(context.Background()).Clauses(clause.OnConflict{
		Columns:   []clause.Column{{Name: "id"}},                                                         // The key to match on
		DoUpdates: clause.AssignmentColumns([]string{"liquidity0", "liquidity1", "liquidityu", "block"}), // Only update field ''
	}).Create(updates...)
	if err != nil {
		mgr.alerter.AlertText("DexManager.UpdateDBPoolLiqBatch: update pool liquidity batch failed", err)
	}
	return err
}

func (mgr *DexManager) DbUpdateTokenDynBatch(chainid int64, ids []int64, priceus []float64, bestPoolIds []int64, bestPoolVliqs []float64) error {

	if len(ids) != len(priceus) || len(ids) != len(bestPoolIds) || len(ids) != len(bestPoolVliqs) {
		return errors.New("DexManager.DbUpdateTokenPriceuBatch: input slices length mismatch")
	}

	updates := make([]*model.TTokenDynamic, 0, len(ids))
	for i, id := range ids {
		tkn := &model.TTokenDynamic{
			ID:           id,
			Priceu:       priceus[i],
			BestPoolID:   bestPoolIds[i],
			BestPoolVliq: bestPoolVliqs[i],
		}
		updates = append(updates, tkn)
	}

	err := query.TTokenDynamic.WithContext(context.Background()).Clauses(clause.OnConflict{
		Columns:   []clause.Column{{Name: "id"}},                                                  // The key to match on
		DoUpdates: clause.AssignmentColumns([]string{"priceu", "best_pool_id", "best_pool_vliq"}), // Only update field ''
	}).Create(updates...)

	if err != nil {
		mgr.alerter.AlertText("DexManager.UpdateDBTokenPriceuBatch: update token priceu batch failed", err)
	}
	return err
}

func (mgr *DexManager) GetDexPoolByID(id int64) (*model.TDexPool, bool) {
	pool, ok := mgr.idDexPools[id]
	return pool, ok
}

func (mgr *DexManager) GetLaunchpadByID(id int64) (*model.TLaunchpad, bool) {
	lp, ok := mgr.idLaunchpads[id]
	return lp, ok
}

func (mgr *DexManager) GetDexByID(id int64) (*model.TDex, bool) {
	dex, ok := mgr.idDexs[id]
	return dex, ok
}

func (mgr *DexManager) GetAllDexIds() []int64 {
	ids := make([]int64, 0, len(mgr.idDexs))
	for id := range mgr.idDexs {
		ids = append(ids, id)
	}
	return ids
}

func (mgr *DexManager) GetAllLaunchpadIds() []int64 {
	ids := make([]int64, 0, len(mgr.idLaunchpads))
	for id := range mgr.idLaunchpads {
		ids = append(ids, id)
	}
	return ids
}

func (mgr *DexManager) GetDexByFactory(factory string) (*model.TDex, *model.TDexPool, bool) {
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

// can't reload without mutex
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

	mgr.chainFamousTokens = chainFamousToken
	mgr.idDexs = idDexs
	mgr.idDexPools = idDexPools
	mgr.idLaunchpads = idLaunchpads
	mgr.factoryDexPools = factoryDexPools
	mgr.factoryLaunchpads = factoryLaunchpads
}
