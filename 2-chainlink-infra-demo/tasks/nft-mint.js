// const { deployments } = require("hardhat")
const { task } = require("hardhat/config")

task("mint-nft")
    .addParam("uri", "nft token URI")
    .setAction(async(taskArgs, hre) => {
    const {firstAccount} = await getNamedAccounts()

    const nftDeployment = await deployments.get("MyNFT")
    const nft = await ethers.getContractAt("MyNFT", nftDeployment.address)

    console.log(`nft address is ${nft.target}`)

    console.log("minting NFT...")
    const mintTx = await nft.safeMint(firstAccount, taskArgs.uri)
    await mintTx.wait(6)
    const tokenAmount = await nft.totalSupply()
    const tokenId = tokenAmount - 1n
    console.log(`NFT minted, tokenId is ${tokenId}`)
})


module.exports = {}