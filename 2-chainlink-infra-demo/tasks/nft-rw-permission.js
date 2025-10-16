const { task } = require("hardhat/config")
const { networkConfig } = require("../helper-hardhat-config")
//const { network, getNamedAccounts, deployments } = require("hardhat")

task("rw-permission")
    .addParam("tokenid", "tokenId to be locked and crossed")
    .addOptionalParam("setting", "whether to setup allowlist", undefined, types.boolean)
    .addOptionalParam("approve", "whether to call nft.approve", undefined, types.boolean)
    .setAction(async(taskArgs, hre) => {
        const tokenId = taskArgs.tokenid

        let lockPool, burnPool
        const settingProvided = taskArgs.setting !== undefined
        if (settingProvided) {
            if (network.name === "sepolia") {
                const nftDeployment = await deployments.get("MyNFT")
                const nft = await ethers.getContractAt("MyNFT", nftDeployment.address)

                const lockPoolDeployment = await deployments.get("NFTPoolLockAndRelease")
                lockPool = await ethers.getContractAt("NFTPoolLockAndRelease", lockPoolDeployment.address)
                const burnPoolAddr = (await hre.companionNetworks["destChain"].deployments.get("NFTPoolBurnAndMint")).address

                const companionChainSelector = networkConfig[network.config.chainId].companionChainSelector
                console.log(`ready to call allowlist methods, companionChainSelector: ${companionChainSelector}, burnPoolAddr: ${burnPoolAddr}`)

                await lockPool.allowlistDestinationChain(companionChainSelector, true)
                await lockPool.allowlistSender(burnPoolAddr, true)
                await lockPool.allowlistSourceChain(companionChainSelector, true)
                console.log("set permission on sepolia done")
            } else if (network.name === "fuji") {
                const wnftDeployment = await deployments.get("WrappedNFT")
                const wnft = await ethers.getContractAt("WrappedNFT", wnftDeployment.address)
                const burnPoolDeployment = await deployments.get("NFTPoolBurnAndMint")
                burnPool = await ethers.getContractAt("NFTPoolBurnAndMint", burnPoolDeployment.address)
                const lockPoolAddr = (await hre.companionNetworks["destChain"].deployments.get("NFTPoolLockAndRelease")).address
                const companionChainSelector = networkConfig[network.config.chainId].companionChainSelector
                console.log(`ready to call allowlist methods, companionChainSelector: ${companionChainSelector}, lockPoolAddr: ${lockPoolAddr}`)

                // Check if the wrapped NFT exists before approving
                try {
                    const owner = await wnft.ownerOf(tokenId)
                    console.log(`WrappedNFT ${tokenId} exists, owner: ${owner}`)
                    await wnft.approve(burnPool.target, tokenId)
                    console.log("WrappedNFT approved")
                } catch (error) {
                    console.log(`WrappedNFT ${tokenId} does not exist yet, error: ${error.message}`)
                }

                await burnPool.allowlistDestinationChain(companionChainSelector, true)
                await burnPool.allowlistSender(lockPoolAddr, true)
                await burnPool.allowlistSourceChain(companionChainSelector, true)
                console.log("set permission on fuji done")
            }
        } else {
            console.log("reading permission status...")
            if (network.name === "sepolia") {
                const lockPoolDeployment = await deployments.get("NFTPoolLockAndRelease")
                lockPool = await ethers.getContractAt("NFTPoolLockAndRelease", lockPoolDeployment.address)
                const burnPoolAddr = (await hre.companionNetworks["destChain"].deployments.get("NFTPoolBurnAndMint")).address
                const isAllowed = await lockPool.allowlistedSenders(burnPoolAddr)
                console.log(`is burnPool allowlisted as sender on lockPool: ${isAllowed}`)
            } else if (network.name === "fuji") {
                const burnPoolDeployment = await deployments.get("NFTPoolBurnAndMint")
                burnPool = await ethers.getContractAt("NFTPoolBurnAndMint", burnPoolDeployment.address)
                const lockPoolAddr = (await hre.companionNetworks["destChain"].deployments.get("NFTPoolLockAndRelease")).address
                const isAllowed = await burnPool.allowlistedSenders(lockPoolAddr)
                console.log(`is lockPool allowlisted as sender on burnPool: ${isAllowed}`)
            }
        }

        const approveProvided = taskArgs.approve !== undefined
        if (approveProvided) {
            console.log("calling nft.approve...")
            if (network.name === "sepolia") {
                const nftDeployment = await deployments.get("MyNFT")
                const nft = await ethers.getContractAt("MyNFT", nftDeployment.address)
                await nft.approve(lockPool.target, tokenId)
            } else if (network.name === "fuji") {
                const wnftDeployment = await deployments.get("WrappedNFT")
                const wnft = await ethers.getContractAt("WrappedNFT", wnftDeployment.address)
                await wnft.approve(burnPool.target, tokenId)
            }
        }
    })

module.exports = {}