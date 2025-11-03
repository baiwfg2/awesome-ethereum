## Monolithic Foundry Project

At the begining of the repo, I planned to arrage each project as separate hardhat or foundry project. However, many identical folders and submodules exist in separate projects which wastes space.

Since I'm preferably happy to use foundry, I started to build an integrated foundry project which contains all of following smart contracts. Probably I'll migrate old smart contracts into here.

# setup

```
forge install Cyfrin/foundry-devops

make deploy ARGS="--network sepolia" (see results in ./notes/)
make upgrade ARGS="--network sepolia" (set ffi=true)
make interact ARGS="--network sepolia"
```



## current smart contracts

### Securities

to-be-greately expolored

### Gas Optimizations

to-be-greatly explored