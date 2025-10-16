const { task } = require("hardhat/config")
const { networkConfig } = require("../helper-hardhat-config")

task("burn-and-cross")
    .addParam("tokenid", "tokenId to be locked and crossed")
    .addOptionalParam("chainselector", "chain selector of destination chain")
    .addOptionalParam("receiver", "receiver in the destination chain")
    .setAction(async(taskArgs, hre) => {
        const tokenId = taskArgs.tokenid

        const { firstAccount } = await getNamedAccounts()
        const burnPoolDeployment = await deployments.get("NFTPoolBurnAndMint")
        const burnPool = await ethers.getContractAt("NFTPoolBurnAndMint", burnPoolDeployment.address)

        // get receiver contract
        // deployed contract will be used if there is no receiver provided
        let destReceiver
        if(taskArgs.receiver) {
            destReceiver = taskArgs.receiver
        } else {
            // 这里注意获取目标链的deployment 对象
            const lockPoolDeployment = await hre.companionNetworks["destChain"].deployments.get("NFTPoolLockAndRelease")
            destReceiver = lockPoolDeployment.address
        }

        // get the chain selector of destination chain
        // deployed contract will be used if there is no chain selector provided
        let destChainSelector
        if(taskArgs.chainselector) {
            destChainSelector = taskArgs.chainselector
        } else {
            destChainSelector = networkConfig[network.config.chainId].companionChainSelector
        }
        console.log(`destination chain selector is ${destChainSelector}`)

        const linkTokenAddr = networkConfig[network.config.chainId].linkToken
        const linkToken = await ethers.getContractAt("LinkToken", linkTokenAddr)

        /////////// 在真正调send之前，pool得有LINK支持费用，且得有权限调MyNFT的发送方法
        // transfer 10 LINK token from deployer to pool
        const balanceBefore = await linkToken.balanceOf(burnPool.target)
        console.log(`balance: ${balanceBefore}`)
        if (balanceBefore < ethers.parseEther("10")) {
            const transferTx = await linkToken.transfer(burnPool.target, ethers.parseEther("10"))
            await transferTx.wait(6)
            const balanceAfter = await linkToken.balanceOf(burnPool.target)
            console.log(`balance after airdrop from LinkToken: ${balanceAfter}`)
        }

        // do in a separate script
        //await setupAllowlists(lockPool, burnPool, destChainSelector, srcChainSelector)

        // ccip send
        const lockAndCrossTx = await burnPool.burnAndSendNft(
            tokenId,
            firstAccount,
            destChainSelector,
            destReceiver
        )

        console.log(`Transaction sent: ${lockAndCrossTx.hash}`)
        console.log("Waiting for confirmation...")

        const receipt = await lockAndCrossTx.wait(6)
        console.log(`NFT locked and crossed successfully! Block: ${receipt.blockNumber}`)

        // Log events if any
        if (receipt.logs && receipt.logs.length > 0) {
            console.log(`Transaction generated ${receipt.logs.length} events`)
        }
})

module.exports = {}