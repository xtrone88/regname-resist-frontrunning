const { expect } = require("chai")
const { ethers, waffle } = require("hardhat")
const BN = ethers.BigNumber

describe('RegisterName contract', function () {

    let owner, tester1, tester2, tester3
    let transactionId = 0, totalFee = BN.from(0);
    let regContract

    before(async () => {
        const RegContract = await ethers.getContractFactory("RegisterName")
        regContract = await RegContract.deploy()
        await regContract.deployed()

        const signers = await ethers.getSigners()
        owner  = signers[0]
        tester1 = signers[1]
        tester2 = signers[2]
        tester3 = signers[3]
    })

    it('getTransactionId-1', async () => {
        transactionId++
        const tx = await regContract.connect(tester1).newTransactionId()
        await tx.wait()
        expect(await regContract.connect(tester1).getTransactionId()).to.equal(transactionId)
    })

    it('registerName-1', async () => {
        const name = 'tester1-xyz'
        const fee = ethers.utils.parseUnits('1000', 'gwei').mul(BN.from(ethers.utils.toUtf8Bytes(name).length))
        totalFee = totalFee.add(fee)
        const tx = await regContract.connect(tester1).registerName(name, {value: ethers.utils.parseEther('1').add(fee)})
        tx.wait()

        const regState = await regContract.connect(tester1).getRegState(name)
        expect(regState.balance).to.equal(ethers.utils.parseEther('1'))
    })

    it('getTransactionId-2', async () => {
        transactionId++
        const tx = await regContract.connect(tester2).newTransactionId()
        await tx.wait()
        expect(await regContract.connect(tester2).getTransactionId()).to.equal(transactionId)
    })

    it('registerName-2', async () => {
        const name = 'tester2-xyz'
        const fee = ethers.utils.parseUnits('1000', 'gwei').mul(BN.from(ethers.utils.toUtf8Bytes(name).length))
        totalFee = totalFee.add(fee)
        const tx = await regContract.connect(tester2).registerName(name, {value: ethers.utils.parseEther('1').add(fee)})
        tx.wait()

        const regState = await regContract.connect(tester2).getRegState(name)
        expect(regState.balance).to.equal(ethers.utils.parseEther('1'))
    })

    it('Fail on registration', async () => {
        let tx = await regContract.connect(tester3).newTransactionId()
        await tx.wait()

        const name = 'tester3-xyz'
        tx = await regContract.connect(tester3).registerName(name)
        tx.wait()
    })

    it('allowNextTransaction', async () => {
        transactionId++
        await regContract.connect(tester3).allowNextTransaction()
        expect(await regContract.connect(tester3).getTransactionId()).to.equal(transactionId)
    })
        
    it('getTransactionId-3', async () => {
        transactionId++
        const tx = await regContract.connect(tester3).newTransactionId()
        await tx.wait()
        expect(await regContract.connect(tester3).getTransactionId()).to.equal(transactionId)
    })

    it('registerName-3', async () => {
        const name = 'tester1-xyz'
        const fee = ethers.utils.parseUnits('1000', 'gwei').mul(BN.from(ethers.utils.toUtf8Bytes(name).length))
        totalFee = totalFee.add(fee)
        const tx = await regContract.connect(tester3).registerName(name, {value: ethers.utils.parseEther('1').add(fee)})
        tx.wait()

        const regState = await regContract.connect(tester3).getRegState(name)
        expect(regState.balance).to.equal(ethers.utils.parseEther('1'))
    })

    it('getTransactionId-4', async () => {
        transactionId++
        const tx = await regContract.connect(tester2).newTransactionId()
        await tx.wait()
        expect(await regContract.connect(tester2).getTransactionId()).to.equal(transactionId)
    })

    it('Renew-2', async () => {
        const name = 'tester2-xyz'
        const fee = ethers.utils.parseUnits('1000', 'gwei').mul(BN.from(ethers.utils.toUtf8Bytes(name).length))
        totalFee = totalFee.add(fee)
        const tx = await regContract.connect(tester2).registerName(name, {value: ethers.utils.parseEther('1').add(fee)})
        tx.wait()

        const regState = await regContract.connect(tester2).getRegState(name)
        expect(regState.balance).to.equal(ethers.utils.parseEther('2'))
    })

    it('withraw-1', async () => {
        expect(await regContract.connect(tester1).getUnlockedBalance()).to.equal(ethers.utils.parseEther('1'))

        const name = 'tester1-xyz'
        const tx = await regContract.connect(tester1).withraw(name)
        tx.wait()

        // const regState = await regContract.connect(tester1).getRegState(name)
        // expect(regState.balance).to.equal(0)

        expect(await regContract.connect(tester1).getUnlockedBalance()).to.equal(0)
    })

    it('withraw-2', async () => {
        const name = 'tester2-xyz'
        const tx = await regContract.connect(tester2).withraw(name)
        tx.wait()

        const regState = await regContract.connect(tester2).getRegState(name)
        expect(regState.balance).to.equal(0)
    })

    it('withraw-3', async () => {
        const name = 'tester1-xyz'
        const tx = await regContract.connect(tester3).withraw(name)
        tx.wait()

        const regState = await regContract.connect(tester3).getRegState(name)
        expect(regState.balance).to.equal(0)
    })

    it('withrawFee', async () => {
        expect(await regContract.getTotalFeeBalance()).to.equal(totalFee)

        const tx = await regContract.withrawFee()
        tx.wait()

        expect(await regContract.getTotalFeeBalance()).to.equal(0)
    })
})