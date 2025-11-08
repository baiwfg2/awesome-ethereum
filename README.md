# awesome ethereum

This repo is for solidity new learners and Ethereum enthusiasts to master basic understanding of blockchain development. It's going to have many different projects that illustrate variaties of use cases. Except for that, I'll explore and share more complex internals about Ethereum and its diverse clients.


## NFT Mint

- By leaveraging openzeppelin ERC721, mint a customized NFT whose metadata stored on pinata
- Use hardhat to deploy contract and use ethers.js to mint a NFT with Alchemy RPC endpoint

## chainlink infrastructure usage

- By using chainlink-ccip, tokens and NFTs can be crossed-chain
- By using chainlink VRF, a censorship-resistant random number could be generated throught oracle network
- By using chainklink automation, a lottery smart contract can arragee multiple rounds of Raffle.

## StableCoin

Build a minimal stablecoin DSC which can be minted by depositing collaterals into a smart contract. If the collateral's price goes down, by chainlink price feed, health factor may be effected. If it goes below one, collaterals could be liquidated.

## Monolithic Foundry Project

Later smart contracts will be included in this project, no more separate foundry project.

## foundry commands examples

```
# generate function selector
cast sig "log(string)"

# encode string
cast abi-encode "log(string)" "Hello World"

# decode calldata bytes
cast calldata-decode "log(string)" 0x41304fac0000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000000b48656c6c6f20576f726c64000000000000000000000000000000000000000000

# generate calldata bytes for function and its parameters, functionally equivalent to `abi.encodeWithSignature`
cast calldata "execute(address,uint256,bytes)" 0x742d35Cc6634C0532925a3b8D53C045d1e84b3C4 0 0x1234

cast keccak "my password"

cast block-number --rpc-url $FORK_URL

# passing fork-block-number can be faster
forge test --fork-url --fork-block-number $FORK_BLOCK_NUM

# common functions can be queried like this, but not for user's customzied functions
cast 4byte 0x1f6a65b6

# query value of a specific slot in storage
cast storage 0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512 2 --rpc-url $RPC_URL

# query the value of a specific slot with curl
# curl -X POST \
  -H "Content-Type: application/json" \
  -d '{
    "jsonrpc": "2.0",
    "method": "eth_getStorageAt",
    "params": ["0x2C98521b3AEa9BFbC54664F4959b750BbaDA9E36", "0x0", "latest"],
    "id": 1
  }' https://eth-sepolia.g.alchemy.com/v2/WxBWzto06cKCPSKnPK2RP
{"jsonrpc":"2.0","id":1,"result":"0x000000000000000000000000a4a8dce9f35c75f57df0449b0543cd767bef6305"}
```

## Note

1. You should take notice of what I've written in git commit message, may be helpful. I like to write down details of a given commit.
2. Also the issues I've written may be beneficial to understand what could be wrong in developing the smart contracts.
2. Some codes may be hard-coded, you should replace with your own.