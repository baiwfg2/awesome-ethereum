// https://www.bilibili.com/video/BV1RFsfe5Ek5?t=8640.6&p=6

const { getNamedAccounts, deployments, ethers } = require("hardhat")
const { expect } = require("chai")

let firstAccount
let nft
let wnft
let poolLnU
let poolMnB
let chainSelector

before(async function () {
    firstAccount = (await getNamedAccounts()).firstAccount
    await deployments.fixture(["all"])

    const nftDeployment = await deployments.get("MyNFT")
    const wnftDeployment = await deployments.get("WrappedNFT")
    const poolLnUDeployment = await deployments.get("NFTPoolLockAndRelease")
    const poolMnBDeployment = await deployments.get("NFTPoolBurnAndMint")
    const ccipLocalSimulatorDeployment = await deployments.get("CCIPLocalSimulator")

    nft = await ethers.getContractAt("MyNFT", nftDeployment.address)
    wnft = await ethers.getContractAt("WrappedNFT", wnftDeployment.address)
    poolLnU = await ethers.getContractAt("NFTPoolLockAndRelease", poolLnUDeployment.address)
    poolMnB = await ethers.getContractAt("NFTPoolBurnAndMint", poolMnBDeployment.address)
    ccipLocalSimulator = await ethers.getContractAt("CCIPLocalSimulator", ccipLocalSimulatorDeployment.address)
    chainSelector = (await ccipLocalSimulator.configuration()).chainSelector_
})


describe("test if the nft can be minted successfully",
    async function () {
        it("test if the owner of nft is minter",
            async function () {
                await nft.safeMint(firstAccount, "")
                const ownerOfNft = await nft.ownerOf(0)
                expect(ownerOfNft).to.equal(firstAccount)
            }
        )
    }
)

describe("test if the nft can be locked and transferred to destchain"
    , async function() {
        it("transfer NFT from source chain to dest chain, check if the nft is locked",
            async function() {
                //await ccipLocalSimulator.requestLinkFromFaucet(poolLnU.target, ethers.parseEther("10"))

                await poolLnU.allowlistDestinationChain(chainSelector, true)
                await poolMnB.allowlistSourceChain(chainSelector, true)
                await poolMnB.allowlistSender(poolLnU.target, true)

                // lock and send with CCIP
                await nft.approve(poolLnU.target, 0)
                console.log("receiver:", poolMnB.target)
                await poolLnU.lockAndSendNft(0, firstAccount, chainSelector, poolMnB.target)

                // check if owner of nft is pool's address
                const newOwner = await nft.ownerOf(0)
                expect(newOwner).to.equal(poolLnU.target)
            }
        )
        // check if the wnft is owned by new owner
        it("check if wnft's account is owner",
            async function() {
                const newOwner = await wnft.ownerOf(0)
                expect(newOwner).to.equal(firstAccount)
            }
        )
    }
)

describe("test if the nft can be burned and transferred back to sourcechain",
    async function() {
        it("wnft can be burned",
            async function() {
                // fund some Link tokens
                //ccipLocalSimulator.requestLinkFromFaucet(poolMnB.target, ethers.parseEther("10"))

                // grant permission
                await wnft.approve(poolMnB.target, 0)
                await poolMnB.allowlistDestinationChain(chainSelector, true)
                await poolLnU.allowlistSourceChain(chainSelector, true)
                await poolLnU.allowlistSender(poolMnB.target, true) // allow poolMnB to send message to poolLnU

                // transfer the token
                await poolMnB.burnAndSendNft(0, firstAccount, chainSelector, poolLnU.target)
                const wnftTotalSupply = await wnft.totalSupply()
                expect(wnftTotalSupply).to.equal(0)
            }
        )
        it("owner of the NFT is transferred to firstAccount",
            async function() {
                const newOwner = await nft.ownerOf(0)
                expect(newOwner).to.equal(firstAccount)
            }
        )
    }
)