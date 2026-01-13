package defi

import (
	"math"
	"math/big"

	"github.com/shopspring/decimal"
)

var XBits = map[int]decimal.Decimal{
	32: decimal.NewFromInt(2).Pow(decimal.NewFromInt(32)),
	64: decimal.NewFromInt(2).Pow(decimal.NewFromInt(64)),
	96: decimal.NewFromInt(2).Pow(decimal.NewFromInt(96)),
}

func SqrtPriceXToPrice(sqrtPriceX *big.Int, zeroForOne bool, bits int) (price decimal.Decimal) {
	d := decimal.NewFromBigInt(sqrtPriceX, 0).Div(XBits[bits])
	p := d.Mul(d)

	if !zeroForOne {
		price = decimal.NewFromInt(1).Div(p)
		return
	}
	price = p
	return
}

func SqrtPriceX96ToPrice(sqrtPriceX96 *big.Int, zeroForOne bool) (price decimal.Decimal) {
	return SqrtPriceXToPrice(sqrtPriceX96, zeroForOne, 96)
}

func SqrtPriceX64ToPrice(sqrtPriceX64 *big.Int, zeroForOne bool) (price decimal.Decimal) {
	return SqrtPriceXToPrice(sqrtPriceX64, zeroForOne, 64)
}

func SqrtPriceX32ToPrice(sqrtPriceX32 *big.Int, zeroForOne bool) (price decimal.Decimal) {
	return SqrtPriceXToPrice(sqrtPriceX32, zeroForOne, 32)
}

// vliq = xy
func IsNewVliqBetter(oldVliq, newVliq float64, decimals int, priceu float64) bool {
	adjust := newVliq / math.Pow(10, float64(decimals))
	adjust = adjust * priceu
	return newVliq > oldVliq
}
