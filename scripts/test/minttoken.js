const { expect } = require("chai");
const { ethers } = require("hardhat");
const { loadFixture } = require("@nomicfoundation/hardhat-network-helpers");

describe("mintTokens contract", function () {
it("Deployment should allow contract owners to mint tokens to an address", async function mintTokenFixture() {
	const [owner, addr1, addr2] = await ethers.getSigners();
	const mintToken = await ethers.getContractFactory("mintTokens");
	const hardhatdeploy = await mintToken.deploy();
	
	let _sampleTokenAddress = "0xed24fc36d5ee211ea25a80239fb8c4cfd80f12ee";
	let _sampleUid = 100;
	let _sampleNewuri = "";
	let _sampleData = 1;
	let _sampleMultipleAddresses = [addr1.address, addr2.address];
	let _sampleID = 1;
	
	const tryToViewTotalSupply = await 		hardhatdeploy.viewTotalSupply(
	_sampleTokenAddress,
	_sampleUid);
	expect(await hardhatdeploy.viewTotalSupply(
	_sampleTokenAddress,
	_sampleUid)).to.be.not.reverted
	
	const tryToMintUniqueNft = await hardhatdeploy.mintUniqueNft(
	addr2.address,
	_sampleData,
	_sampleNewuri);
	expect(await hardhatdeploy.mintUniqueNft(
	addr2.address,
	_sampleData,
	_sampleNewuri)).to.be.not.reverted
	
	
	const tryToMintCopy = await hardhatdeploy.mintCopy(
	addr2.address,
	_sampleID,
	_sampleData);
	expect(await hardhatdeploy.mintCopy(
	addr2.address,
	_sampleID,
	_sampleData)).to.be.not.reverted
	
	const tryToMintUniqueNftsToMultipleAddresses = await hardhatdeploy.mintUniqueNftsToMultipleAddresses(
	_sampleMultipleAddresses,
	_sampleData,
	_sampleNewuri)
	expect(await hardhatdeploy.mintUniqueNftsToMultipleAddresses(
	_sampleMultipleAddresses,
	_sampleData,
	_sampleNewuri)).to.be.not.reverted
	
	const tryToMintCopiesToMultipleAddresses = await hardhatdeploy.mintCopiesToMultipleAddresses(
	_sampleMultipleAddresses,
	_sampleData,
	_sampleNewuri)
	expect(await hardhatdeploy.mintCopiesToMultipleAddresses(
	_sampleMultipleAddresses,
	_sampleData,
	_sampleNewuri)).to.be.not.reverted
	
	const tryToLockID = await hardhatdeploy.lockID(_sampleID)
	expect(await hardhatdeploy.checkIfLocked(_sampleID)).to.equal(true)

})
})
