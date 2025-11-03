$ make deploy ARGS="--network sepolia"
[⠒] Compiling...
[⠢] Files to compile:
- script/DeployBox.s.sol
[⠔] Compiling 1 files with Solc 0.8.30
[⠒] Solc 0.8.30 finished in 2.24s
Compiler run successful!
Traces:
  [1093093] DeployBox::run()
    ├─ [0] VM::startBroadcast()
    │   └─ ← [Return]
    ├─ [905703] → new BoxV1@0x3167C5ffc74E6C524a306EAd99E4beC375906a79
    │   ├─ emit Initialized(version: 18446744073709551615 [1.844e19])
    │   └─ ← [Return] 4404 bytes of code
    ├─ [67212] → new ERC1967Proxy@0x4e986F419907ebcE18022E774664CB10A9b64D78
    │   ├─ emit Upgraded(implementation: BoxV1: [0x3167C5ffc74E6C524a306EAd99E4beC375906a79])
    │   └─ ← [Return] 212 bytes of code
    ├─ [50133] ERC1967Proxy::fallback()
    │   ├─ [49665] BoxV1::initialize() [delegatecall]
    │   │   ├─ emit OwnershipTransferred(previousOwner: 0x0000000000000000000000000000000000000000, newOwner: 0xA4a8dcE9F35C75f57dF0449B0543Cd767BeF6305)
    │   │   ├─ emit Initialized(version: 1)
    │   │   └─ ← [Stop]
    │   └─ ← [Return]
    ├─ [0] VM::stopBroadcast()
    │   └─ ← [Return]
    └─ ← [Return] ERC1967Proxy: [0x4e986F419907ebcE18022E774664CB10A9b64D78]


Script ran successfully.

== Return ==
0: address 0x4e986F419907ebcE18022E774664CB10A9b64D78

## Setting up 1 EVM.
==========================
Simulated On-chain Traces:

  [905703] → new BoxV1@0x3167C5ffc74E6C524a306EAd99E4beC375906a79
    ├─ emit Initialized(version: 18446744073709551615 [1.844e19])
    └─ ← [Return] 4404 bytes of code

  [69712] → new ERC1967Proxy@0x4e986F419907ebcE18022E774664CB10A9b64D78
    ├─ emit Upgraded(implementation: BoxV1: [0x3167C5ffc74E6C524a306EAd99E4beC375906a79])
    └─ ← [Return] 212 bytes of code

  [54633] ERC1967Proxy::fallback()
    ├─ [49665] BoxV1::initialize() [delegatecall]
    │   ├─ emit OwnershipTransferred(previousOwner: 0x0000000000000000000000000000000000000000, newOwner: 0xA4a8dcE9F35C75f57dF0449B0543Cd767BeF6305)
    │   ├─ emit Initialized(version: 1)
    │   └─ ← [Stop]
    └─ ← [Return]


==========================

Chain 11155111

Estimated gas price: 0.001000018 gwei

Estimated total gas used for script: 1641327

Estimated amount required: 0.000001641356543886 ETH

==========================

##### sepolia
✅  [Success] Hash: 0xb86ee7c9528dcad55f0588db6f061a13993cfaf861814ad9ef820c5a485c0b19
Contract Address: 0x4e986F419907ebcE18022E774664CB10A9b64D78
Block: 9550168
Paid: 0.000000146935322406 ETH (146934 gas * 0.001000009 gwei)


##### sepolia
✅  [Success] Hash: 0xad009284b4b37bfbb2397f71dc6e40cfa0ac7c4b989fc3850ce943a446a08687
Contract Address: 0x3167C5ffc74E6C524a306EAd99E4beC375906a79
Block: 9550168
Paid: 0.000001030476274203 ETH (1030467 gas * 0.001000009 gwei)


##### sepolia
✅  [Success] Hash: 0xc106eb71dd7722a0e20d36fab5c579c3903fc8d550e9a42daacb6fb0c7f79bac
Block: 9550168
Paid: 0.000000075697681273 ETH (75697 gas * 0.001000009 gwei)

✅ Sequence #1 on sepolia | Total Paid: 0.000001253109277882 ETH (1253098 gas * avg 0.001000009 gwei)


==========================

ONCHAIN EXECUTION COMPLETE & SUCCESSFUL.
##
Start verification for (2) contracts
Start verifying contract `0x3167C5ffc74E6C524a306EAd99E4beC375906a79` deployed on sepolia
EVM version: prague
Compiler version: 0.8.30

Submitting verification for [src/proxy/BoxV1.sol:BoxV1] 0x3167C5ffc74E6C524a306EAd99E4beC375906a79.
Warning: Could not detect the deployment.; waiting 5 seconds before trying again (4 tries remaining)

Submitting verification for [src/proxy/BoxV1.sol:BoxV1] 0x3167C5ffc74E6C524a306EAd99E4beC375906a79.
Warning: Could not detect the deployment.; waiting 5 seconds before trying again (3 tries remaining)

Submitting verification for [src/proxy/BoxV1.sol:BoxV1] 0x3167C5ffc74E6C524a306EAd99E4beC375906a79.
Warning: Could not detect the deployment.; waiting 5 seconds before trying again (2 tries remaining)

Submitting verification for [src/proxy/BoxV1.sol:BoxV1] 0x3167C5ffc74E6C524a306EAd99E4beC375906a79.
Warning: Could not detect the deployment.; waiting 5 seconds before trying again (1 tries remaining)

Submitting verification for [src/proxy/BoxV1.sol:BoxV1] 0x3167C5ffc74E6C524a306EAd99E4beC375906a79.
Submitted contract for verification:
        Response: `OK`
        GUID: `yrj3d5hmmfz8zwrwuhrleadu3cnadbqynpsn9au9m17aaadjd5`
        URL: https://sepolia.etherscan.io/address/0x3167c5ffc74e6c524a306ead99e4bec375906a79
Contract verification status:
Response: `NOTOK`
Details: `Pending in queue`
Warning: Verification is still pending...; waiting 15 seconds before trying again (7 tries remaining)
Contract verification status:
Response: `OK`
Details: `Pass - Verified`
Contract successfully verified
Start verifying contract `0x4e986F419907ebcE18022E774664CB10A9b64D78` deployed on sepolia
EVM version: prague
Compiler version: 0.8.30
Constructor args: 0000000000000000000000003167c5ffc74e6c524a306ead99e4bec375906a7900000000000000000000000000000000000000000000000000000000000000400000000000000000000000000000000000000000000000000000000000000000

Submitting verification for [lib/openzeppelin-contracts/contracts/proxy/ERC1967/ERC1967Proxy.sol:ERC1967Proxy] 0x4e986F419907ebcE18022E774664CB10A9b64D78.
Submitted contract for verification:
        Response: `OK`
        GUID: `gsq6dylugnec2dwe7kue529qipkk2kwynktuhmp5cmiwcj4j2d`
        URL: https://sepolia.etherscan.io/address/0x4e986f419907ebce18022e774664cb10a9b64d78
Contract verification status:
Response: `NOTOK`
Details: `Pending in queue`
Warning: Verification is still pending...; waiting 15 seconds before trying again (7 tries remaining)
Contract verification status:
Response: `OK`
Details: `Pass - Verified`
Contract successfully verified
All (2) contracts were verified!

Transactions saved to: E:/workspace/web3/solidity-demos/foundry\broadcast\DeployBox.s.sol\11155111\run-latest.json

Sensitive values saved to: E:/workspace/web3/solidity-demos/foundry/cache\DeployBox.s.sol\11155111\run-latest.json