const { expect } = require("chai");
const { ethers } = require("hardhat");
const { loadFixture } = require("@nomicfoundation/hardhat-network-helpers");

describe("mintTokens contract", function () {
	async function mintTokenFixture() {
		const [owner, addr1, addr2] = await ethers.getSigners();
		const mintToken = await ethers.getContractFactory("mintTokens");
		const hardhatdeploy = await mintToken.deploy();
	
		let _sampleTokenAddress = "0xed24fc36d5ee211ea25a80239fb8c4cfd80f12ee";
		let _sampleUid = 100;
		let _sampleNewuri = "";
		let _sampleData = 1;
		let _sampleMultipleAddresses = [addr1.address, addr2.address];
		let _sampleID = 1;
	
		return { mintToken,
			hardhatdeploy,
			owner, 
			addr1, 
			addr2, 
			_sampleTokenAddress, 
			_sampleUid, 
			_sampleNewuri, 
			_sampleData, 
			_sampleMultipleAddresses, 
			_sampleID 
		       };
}
	
	it("should view total supply", async function () {
		const { mintToken, 
		       hardhatdeploy, 
		       _sampleTokenAddress, 
		       _sampleUid
		      } = await loadFixture(mintTokenFixture);
		const tryToViewTotalSupply = await hardhatdeploy.viewTotalSupply(
			_sampleTokenAddress,
			_sampleUid);
		expect(await hardhatdeploy.viewTotalSupply(
			_sampleTokenAddress,
			_sampleUid)).to.be.not.reverted
	})
	
	it("should mint unique nft", async function () {
		const { mintToken, 
		       hardhatdeploy, 
		       owner, 
		       addr1, 
		       addr2, 
		       _sampleNewuri, 
		       _sampleData
		      } = await loadFixture(mintTokenFixture);
		const tryToMintUniqueNft = await hardhatdeploy.mintUniqueNft(
			addr2.address,
			_sampleData,
			_sampleNewuri);
		expect(await hardhatdeploy.mintUniqueNft(
			addr2.address,
			_sampleData,
			_sampleNewuri)).to.be.not.reverted
	})
	
	
	it("should mint a copy nft from an existing nft", async function () {
		const { mintToken, 
		       hardhatdeploy, 
		       owner, 
		       addr1, 
		       addr2, 
		       _sampleNewuri, 
		       _sampleData, 
		       _sampleID
		      } = await loadFixture(mintTokenFixture);
		const _account = addr2.address;
		//mibt nft to copy from
		const tryToMintUniqueNft = await hardhatdeploy.mintUniqueNft(
			addr2.address,
			_sampleData,
			_sampleNewuri);
		//try to copy the minted unique NFT
		const tryToMintCopy = await hardhatdeploy.mintCopy(
			_account,
			_sampleID,
			_sampleData);
		expect(await hardhatdeploy.mintCopy(
			_account,
			_sampleID,
			_sampleData)).to.be.not.reverted
	});
	
	it("should mint nft to multiple addresses", async function () {
		const { mintToken, 
		       hardhatdeploy, 
		       owner, 
		       addr1, 
		       addr2,
		       _sampleNewuri, 
		       _sampleData, 
		       _sampleMultipleAddresses 
		      } = await loadFixture(mintTokenFixture);
		const tryToMintUniqueNftsToMultipleAddresses = await hardhatdeploy.mintUniqueNftsToMultipleAddresses(
			_sampleMultipleAddresses,
			_sampleData,
			_sampleNewuri)
		await expect(hardhatdeploy.mintUniqueNftsToMultipleAddresses(
			_sampleMultipleAddresses,
			_sampleData,
			_sampleNewuri)).to.be.not.reverted
	})
	
	it("should mint copy to multiple addresses", async function () {
		const { mintToken, 
		       hardhatdeploy, 
		       owner, 
		       addr1, 
		       addr2,
		       _sampleNewuri, 
		       _sampleData, 
		       _sampleMultipleAddresses 
		      } = await loadFixture(mintTokenFixture);
		const tryToMintCopiesToMultipleAddresses = await hardhatdeploy.mintCopiesToMultipleAddresses(
			_sampleMultipleAddresses,
			_sampleData,
			_sampleNewuri)
		await expect(hardhatdeploy.mintCopiesToMultipleAddresses(
			_sampleMultipleAddresses,
			_sampleData,
			_sampleNewuri)).to.be.not.reverted
	})
	
	it("should check if locked", async function () {
		const { mintToken, 
		       hardhatdeploy, 
		       _sampleID 
		      } = await loadFixture(mintTokenFixture);
		await expect(await hardhatdeploy.checkIfLocked(_sampleID)).to.equal(false)
	})	
	
	it("should lock the ID", async function () {
		const { mintToken, 
		       hardhatdeploy, 
		       _sampleID 
		      } = await loadFixture(mintTokenFixture);
		const tryToLockID = await hardhatdeploy.lockID(_sampleID)
		await expect(await hardhatdeploy.checkIfLocked(_sampleID)).to.equal(true)
	})

	it("should fail to mint unique nft with a locked ID", async function () {
		const { mintToken, 
		       hardhatdeploy, 
		       owner, 
		       addr1, 
		       addr2, 
		       _sampleNewuri, 
		       _sampleData,
		       _sampleID
		      } = await loadFixture(mintTokenFixture);
		const tryToLockID = await hardhatdeploy.lockID(_sampleID)
		await expect(hardhatdeploy.mintUniqueNft(
			addr2.address,
			_sampleData,
			_sampleNewuri)).to.be.revertedWith("This ID is locked");
	})

	it("should fail to mint a copy nft from an existing nft due to lock", async function () {
		const { mintToken, 
		       hardhatdeploy, 
		       owner, 
		       addr1, 
		       addr2, 
		       _sampleNewuri, 
		       _sampleData, 
		       _sampleID
		      } = await loadFixture(mintTokenFixture);
		const _account = addr2.address;
		const tryToMintUniqueNft = await hardhatdeploy.mintUniqueNft(
			addr2.address,
			_sampleData,
			_sampleNewuri);
		const tryToLockID = await hardhatdeploy.lockID(_sampleID)
		await expect(hardhatdeploy.mintCopy(
			_account,
			_sampleID,
			_sampleData)).to.be.revertedWith("This ID is locked");
	});

	it("should fail to mint a copy nft from a non-existent nft", async function () {
		const { mintToken, 
		       hardhatdeploy, 
		       owner, 
		       addr1, 
		       addr2, 
		       _sampleNewuri, 
		       _sampleData, 
		       _sampleID
		      } = await loadFixture(mintTokenFixture);
		const _account = addr2.address;
		await expect(hardhatdeploy.mintCopy(
			_account,
			_sampleID,
			_sampleData)).to.be.reverted;
	});

})
