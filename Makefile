# include .env file and export its env vars
# (-include to ignore error if it does not exist)
-include .env

# deps
update:; forge update

# Build & test
build  :; forge build --sizes --via-ir
test   :; forge test -vvv --rpc-url=${ETH_RPC_URL} --fork-block-number 16023000 --via-ir
trace   :; forge test -vvvv --rpc-url=${ETH_RPC_URL} --fork-block-number 16023000 --via-ir
clean  :; forge clean
snapshot :; forge snapshot

# utils
download :; ETHERSCAN_API_KEY=${ETHERSCAN_API_KEY} cast etherscan-source -d src/etherscan/${address} ${address} 
rinkeby-download :; ETHERSCAN_API_KEY=${ETHERSCAN_API_KEY} cast etherscan-source -c rinkeby -d src/etherscan/${address} ${address} 

# deploy
rinkeby-deploy :; forge script script/FeiRiskParamsUpdatePayload.s.sol:FeiRiskParamsUpdateDeployScript --rpc-url=${RINKEBY_RPC_URL} --private-key ${PRIVATE_KEY} --broadcast --verify --via-ir

deploy :;  forge script script/FeiRiskParamsUpdatePayload.s.sol:FeiRiskParamsUpdateDeployScript --rpc-url=${ETH_RPC_URL} --ledger --sender 0xde30040413b26d7aa2b6fc4761d80eb35dcf97ad --broadcast --verify --via-ir

submit :;  forge script script/FeiRiskParamsUpdateSubmission.s.sol:FeiRiskParamsUpdateSubmitScript --rpc-url=${ETH_RPC_URL} --private-key ${PRIVATE_KEY} --broadcast --verify --via-ir


# verify
verify :; forge verify-contract --compiler-version 0.8.11+commit.d7f03943 --optimizer-runs 200 0x6539eD4E0db483C128ae15546FA6d715bE00f1a0 ./src/FeiRiskParamsUpdate.sol:FeiRiskParamsUpdate
