package loader

import (
	"sync"

	"github.com/dexerlab/utils-go/dal/model"
	"github.com/dexerlab/utils-go/util"
)

type TokenStatic = model.TTokenStatic

type TokenStaticManager struct {
	addressTokens map[string]*TokenStatic
	mutex         *sync.RWMutex
}

func NewTokenStaticManager() *TokenStaticManager {

	return &TokenStaticManager{
		addressTokens: make(map[string]*TokenStatic),
		mutex:         &sync.RWMutex{},
	}
}

func (mgr *TokenStaticManager) AddTokenStatic(address string, token *TokenStatic) {
	mgr.mutex.Lock()
	defer mgr.mutex.Unlock()

	mgr.addressTokens[util.NormalizeAddress(address)] = token
}

func (mgr *TokenStaticManager) GetByAddress(address string) (*TokenStatic, bool) {
	mgr.mutex.RLock()
	defer mgr.mutex.RUnlock()
	token, ok := mgr.addressTokens[util.NormalizeAddress(address)]
	return token, ok
}
