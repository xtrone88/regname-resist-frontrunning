const { ethers, upgrades } = require("hardhat")

async function main() {
  const RegContract = await ethers.getContractFactory("RegisterName")
  regContract = await RegContract.deploy()
  await regContract.deployed()
  console.log("RegisterName deployed to:", regContract.address)
}

main()
.then(() => process.exit(0))
.catch((error) => {
    console.error(error)
    process.exit(1)
})