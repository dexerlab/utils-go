# utils-go
golang utils

go install github.com/ethereum/go-ethereum/cmd/abigen@latest
abigen --abi uniswapv3.json --pkg uniswap  --type UniswapV3 --out uniswapv3.go

go install github.com/gagliardetto/anchor-go@latest
anchor-go --idl fun.json --name pumpfun  -no-go-mod   --output ./