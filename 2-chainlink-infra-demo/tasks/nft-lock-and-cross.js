const { task } = require("hardhat/config")
const { networkConfig } = require("../helper-hardhat-config")

// Function to setup allowlists for cross-chain NFT transfer
async function setupAllowlists(lockPool, burnPool, destChainSelector, srcChainSelector) {
    console.log("Setting up allowlists...")

    // Check and allowlist destination chain on source pool
    const isDestAllowlisted = await lockPool.allowlistedDestinationChains(destChainSelector)
    if (!isDestAllowlisted) {
        console.log("Allowlisting destination chain...")
        const allowlistTx = await lockPool.allowlistDestinationChain(destChainSelector, true)
        await allowlistTx.wait(1)
        console.log("Destination chain allowlisted!")
    }

    // Check and allowlist sender (lockPool) on destination pool
    const isSenderAllowlisted = await burnPool.allowlistedSenders(lockPool.target)
    if (!isSenderAllowlisted) {
        console.log("Allowlisting source chain sender...")
        const allowlistTx = await burnPool.allowlistSender(lockPool.target, true)
        await allowlistTx.wait(1)
        console.log("Source chain sender allowlisted!")
    }

    // Check and allowlist source chain on destination pool
    const isSrcChainAllowlisted = await burnPool.allowlistedSourceChains(srcChainSelector)
    if (!isSrcChainAllowlisted) {
        console.log("Allowlisting source chain...")
        const allowlistTx = await burnPool.allowlistSourceChain(srcChainSelector, true)
        await allowlistTx.wait(1)
        console.log("Source chain allowlisted!")
    }

    console.log("Allowlist setup completed!")
}

task("lock-and-cross")
    .addParam("tokenid", "tokenId to be locked and crossed")
    .addOptionalParam("chainselector", "chain selector of destination chain")
    .addOptionalParam("receiver", "receiver in the destination chain")
    .setAction(async(taskArgs, hre) => {
        const tokenId = taskArgs.tokenid

        const { firstAccount } = await getNamedAccounts()
        const lockPoolDeployment = await deployments.get("NFTPoolLockAndRelease")
        const lockPool = await ethers.getContractAt("NFTPoolLockAndRelease", lockPoolDeployment.address)

        // get receiver contract
        // deployed contract will be used if there is no receiver provided
        let destReceiver
        if(taskArgs.receiver) {
            destReceiver = taskArgs.receiver
        } else {
            // 这里注意获取目标链的deployment 对象
            const nftBurnAndMint = await hre.companionNetworks["destChain"].deployments.get("NFTPoolBurnAndMint")
            destReceiver = nftBurnAndMint.address
        }

        // one-off set, better to write within another script
        // const destChainHre = hre.companionNetworks["destChain"]
        // //这样也能拿到abi: (await (hre.artifacts.readArtifact("NFTPoolBurnAndMint"))).abi
        // const burnPoolABI = (await destChainHre.deployments.get("NFTPoolBurnAndMint")).abi
        // const burnPool = new ethers.Contract(destReceiver, burnPoolABI, firstAccount)
        // console.log(`NFTPoolBurnAndMint on destination chain: ${burnPool.target}`)

        // get the chain selector of destination chain
        // deployed contract will be used if there is no chain selector provided
        let destChainSelector
        if(taskArgs.chainselector) {
            destChainSelector = taskArgs.chainselector
        } else {
            destChainSelector = networkConfig[network.config.chainId].companionChainSelector
        }
        console.log(`destination chain selector is ${destChainSelector}`)
        const srcChainSelector = networkConfig[network.config.chainId].chainSelector

        const linkTokenAddr = networkConfig[network.config.chainId].linkToken
        const linkToken = await ethers.getContractAt("LinkToken", linkTokenAddr)

        /////////// 在真正调send之前，pool得有LINK支持费用，且得有权限调MyNFT的发送方法
        // transfer 10 LINK token from deployer to pool
        const balanceBefore = await linkToken.balanceOf(lockPool.target)
        console.log(`balance: ${balanceBefore}`)
        if (balanceBefore < ethers.parseEther("10")) {
            const transferTx = await linkToken.transfer(lockPool.target, ethers.parseEther("10"))
            await transferTx.wait(6)
            const balanceAfter = await linkToken.balanceOf(lockPool.target)
            console.log(`balance after airdrop from LinkToken: ${balanceAfter}`)
        }

        // do in a separate script
        //await setupAllowlists(lockPool, burnPool, destChainSelector, srcChainSelector)

        // ccip send
        const lockAndCrossTx = await lockPool.lockAndSendNft(
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