package loader

import (
	"context"
	"strings"
	"sync"

	"github.com/dexerlab/utils-go/alert"
	"github.com/dexerlab/utils-go/dal/model"
	"github.com/dexerlab/utils-go/dal/query"
	"github.com/dexerlab/utils-go/util"
)

// factory: 0x1..|0x2...|0x3...
type DexManager struct {
	idDex            map[int64]*model.TDex
	factoryDexPool   map[string]*model.TDexPool
	factoryLaunchpad map[string]*model.TLaunchpad
	alerter          alert.Alerter
	mutex            *sync.RWMutex
}

func NewDexManager(alerter alert.Alerter) *DexManager {

	return &DexManager{
		idDex:            make(map[int64]*model.TDex),
		factoryDexPool:   make(map[string]*model.TDexPool),
		factoryLaunchpad: make(map[string]*model.TLaunchpad),
		alerter:          alerter,
		mutex:            &sync.RWMutex{},
	}
}

func (mgr *DexManager) GetDex(factory string) (*model.TDex, *model.TDexPool, bool) {
	mgr.mutex.RLock()
	defer mgr.mutex.RUnlock()
	key := util.NormalizeAddress(factory)
	if key == "" {
		return nil, nil, false
	}

	pool, ok := mgr.factoryDexPool[key]
	if !ok {
		return nil, nil, false
	}

	dex, ok := mgr.idDex[int64(pool.DexID)]
	if !ok {
		return nil, pool, false
	}

	return dex, pool, true
}

func (mgr *DexManager) GetLaunchpad(factory string) (*model.TLaunchpad, bool) {
	mgr.mutex.RLock()
	defer mgr.mutex.RUnlock()
	key := util.NormalizeAddress(factory)
	if key == "" {
		return nil, false
	}
	lp, ok := mgr.factoryLaunchpad[key]
	if !ok {
		return nil, false
	}
	return lp, true
}

func (mgr *DexManager) LoadInfo() {

	// temp maps
	idDex := make(map[int64]*model.TDex)
	factoryDexPool := make(map[string]*model.TDexPool)
	factoryLaunchpad := make(map[string]*model.TLaunchpad)

	// load t_dex
	if dexList, err := query.TDex.WithContext(context.Background()).Find(); err != nil {
		if mgr.alerter != nil {
			mgr.alerter.AlertText("DexManager.LoadInfo: load t_dex failed", err)
		}
	} else {
		for _, d := range dexList {
			idDex[int64(d.ID)] = d
		}
	}

	// load t_dex_pool
	if poolList, err := query.TDexPool.WithContext(context.Background()).Find(); err != nil {
		if mgr.alerter != nil {
			mgr.alerter.AlertText("DexManager.LoadInfo: load t_dex_pool failed", err)
		}
	} else {
		for _, p := range poolList {
			if p == nil {
				continue
			}
			if p.DexID != 0 {
				// ensure dex exists in idDex map later by id
			}
			if pFactory := strings.TrimSpace(p.Factory); pFactory != "" {
				parts := strings.Split(pFactory, "|")
				for _, part := range parts {
					key := util.NormalizeAddress(part)
					if key == "" {
						continue
					}
					factoryDexPool[key] = p
				}
			}
		}
	}

	// load t_launchpad
	if lpList, err := query.TLaunchpad.WithContext(context.Background()).Find(); err != nil {
		if mgr.alerter != nil {
			mgr.alerter.AlertText("DexManager.LoadInfo: load t_launchpad failed", err)
		}
	} else {
		for _, lp := range lpList {
			if lp == nil {
				continue
			}
			if lpFactory := strings.TrimSpace(lp.Factory); lpFactory != "" {
				parts := strings.Split(lpFactory, "|")
				for _, part := range parts {
					key := util.NormalizeAddress(part)
					if key == "" {
						continue
					}
					factoryLaunchpad[key] = lp
				}
			}
		}
	}

	mgr.mutex.Lock()
	mgr.idDex = idDex
	mgr.factoryDexPool = factoryDexPool
	mgr.factoryLaunchpad = factoryLaunchpad
	mgr.mutex.Unlock()
}
