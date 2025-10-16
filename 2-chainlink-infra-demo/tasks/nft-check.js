// const { ethers, deployments } = require("hardhat")
const {task} = require("hardhat/config")

task("check-nft").setAction(async(taskArgs, hre) => {
    const { firstAccount } = await hre.getNamedAccounts()
    let nft
    if (hre.network.name === "sepolia") {
        const nftDeployment = await deployments.get("MyNFT")
        nft = await ethers.getContractAt("MyNFT", nftDeployment.address)
    } else if (hre.network.name === "fuji") {
        const wnftDeployment = await deployments.get("WrappedNFT")
        nft = await ethers.getContractAt("WrappedNFT", wnftDeployment.address)
    }
    console.log("checking nft status ...")
    const totalSupply = await nft.totalSupply()
    for (let id =0; id < totalSupply; id++) {
        const owner = await nft.ownerOf(id)
        console.log(`nft id: ${id}, owner: ${owner}`)
    }
})