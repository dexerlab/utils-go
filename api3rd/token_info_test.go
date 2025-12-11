package api3rd

import (
	"context"
	"encoding/json"
	"testing"

	"github.com/shopspring/decimal"
)

// go test -run TestTokenInfo
func TestTokenInfo(t *testing.T) {
	t.Log("test evm...")
	t.Log(decimal.NewFromFloat(123).Shift(0).String())
	data, err := GetTokenDetails(context.TODO(), "http://127.0.0.1:3000", "SolanaMainnet", []string{"6LYqVzVfqpjVT2dEJqpJG7C4eBNoy3tTTk1u7a4Mpump"}, true, true, true, true)
	t.Log(err)
	b, _ := json.Marshal(data)
	t.Log(string(b))
}
