/*
 *Submitted for verification at polygonscan.com on 2022-xx-xx (YYYY-MM-DD)
*/

// SPDX-License-Identifier: MIT

/*

███╗░░░███╗███████╗████████╗░█████╗░███╗░░██╗░█████╗░██╗░█████╗░
████╗░████║██╔════╝╚══██╔══╝██╔══██╗████╗░██║██╔══██╗██║██╔══██╗
██╔████╔██║█████╗░░░░░██║░░░███████║██╔██╗██║██║░░██║██║███████║
██║╚██╔╝██║██╔══╝░░░░░██║░░░██╔══██║██║╚████║██║░░██║██║██╔══██║
██║░╚═╝░██║███████╗░░░██║░░░██║░░██║██║░╚███║╚█████╔╝██║██║░░██║
╚═╝░░░░░╚═╝╚══════╝░░░╚═╝░░░╚═╝░░╚═╝╚═╝░░╚══╝░╚════╝░╚═╝╚═╝░░╚═╝

    Metanoia is an ecosystem of products that aims to bring 
    real world utility into the web3 space. 

    Learn more about Metanoia in our whitepaper:
    https://docs.metanoia.country/

    Join our community!
    https://discord.gg/YgUus2kddQ


    This is the contract responsible for the sale of the Founding Citizens NFT collection.

*/

pragma solidity 0.8.4;

//import "./Access Control Extension.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/math/Math.sol"; 



interface IMintStorage {
    function preLoadURIs(uint[] memory ids, string[] memory uris) external;
    function mintNextNftToAddress(address to) external;
    function getNextUnusedToken() external view returns(uint);
    function getMaxSupply() external pure returns(uint);
}

interface IPrivilegedListStorage {
    function removeAddress(address address_) external;
    function addCoupon(address address_, uint discountRate, uint numberOfUses) external;
    function useCoupon(address address_, uint discountRate) external;
    function addressHasCoupon(address address_, uint discountRate) external view returns(bool);
}

interface IUsdcStorage {
    function getUsdcBalance(address address_) external view returns(uint);
    function transferUsdcBalance(address from, address to, uint amount) external;
    function increaseUsdcBalance(address address_, uint amount) external;
    function decreaseUsdcBalance(address address_, uint amount) external;
}

//Ownable is not the right access structure - use OpenZeppelin Roles
contract FoundingNFTSale is AccessControl {
    IMintStorage public ERC1155storageContract;
    IPrivilegedListStorage public privilgedBuyerList;
    IUsdcStorage public usdcEscrowStorageContract;
    address public treasuryAddress;

    bytes32 public constant URI_MANAGER_ROLE = keccak256("URI_MANAGER_ROLE");
    bytes32 public constant SALE_MANAGER_ROLE = keccak256("SALE_MANAGER_ROLE");
    bytes32 public constant POST_SALE_MINTER_ROLE = keccak256("POST_SALE_MINTER_ROLE");

    // NEEDS a mapping (uint => address) to store who the original minters were 
    

    uint startTime  = 1893484800; //set to the year 2030 initially, needs to be updated once date is finalized 
	uint topTime	= 1893484820;
    uint endTime    = 1893484900;

    uint constant units = 10**6;
    uint topPrice = 10 * units;
    // uint topPrice = 10000 * units;
    uint BottomPrice = 1000 * units;

    uint constant priceDecreasePerMinute = (units * 25) / 8;

    struct Update {
        uint price;
        uint time;
        bool saleIsLive;
    }
    Update public lastUpdate = Update(10000, block.timestamp, false);

    modifier requiresUpdate() {
        require(lastUpdate.time == block.timestamp, "timestamp is not up-to-date");
        _;
    }

    modifier pushesUpdate() {
        updateState();
        _;
    }

    modifier requiresConsistentState() {
        require(startTime <= endTime, "startTime is later than endTime");
        _;
    }

    constructor() {
        
    }

    function updateState() internal requiresConsistentState {
        //update price
        lastUpdate.price = topPrice - ((block.timestamp - topTime) / 60 * priceDecreasePerMinute);

        //update time
        lastUpdate.time = block.timestamp;
        
        //update saleIsLive
        if (block.timestamp >= startTime && block.timestamp <= endTime) {
            lastUpdate.saleIsLive = true;
        } else {
            lastUpdate.saleIsLive = false;
        }
    }

    function setERC1155StorageContractAddress(address storageAddress) public onlyRole(DEFAULT_ADMIN_ROLE) {
        ERC1155storageContract = IMintStorage(storageAddress);
    }

    function setPrivilegedBuyersListContractAddress(address storageAddress) public onlyRole(DEFAULT_ADMIN_ROLE) {
        privilgedBuyerList = IPrivilegedListStorage(storageAddress);
    }

    function setUsdcEscrowContractAddress(address storageAddress) public onlyRole(DEFAULT_ADMIN_ROLE) {
        usdcEscrowStorageContract = IUsdcStorage(storageAddress);
    }

    function mintNextNftToAddress(address to) internal {
        IMintStorage(ERC1155storageContract).mintNextNftToAddress(to);
    }

    function preLoadURIs(uint[] memory ids, string[] memory uris) 
    public {
        require(
            hasRole(URI_MANAGER_ROLE, _msgSender()) || 
            hasRole(DEFAULT_ADMIN_ROLE, _msgSender()),
            "Sender is not URI Manager or Admin"
        );
        IMintStorage(ERC1155storageContract).preLoadURIs(ids, uris);
    }

    function getNextUnusedToken() public view returns(uint) {
        return IMintStorage(ERC1155storageContract).getNextUnusedToken();
    }

    function getMaxSupply() public view returns(uint) {
        return IMintStorage(ERC1155storageContract).getMaxSupply();
    }

    function setstartTime(uint unixTime) public {
        require(
            hasRole(SALE_MANAGER_ROLE, _msgSender()) || 
            hasRole(DEFAULT_ADMIN_ROLE, _msgSender()),
            "Sender is not Sale Manager or Admin"
        );
        startTime = unixTime;
		topTime = unixTime;
    }

    function setEndTime(uint unixTime) public {
        require(
            hasRole(SALE_MANAGER_ROLE, _msgSender()) || 
            hasRole(DEFAULT_ADMIN_ROLE, _msgSender()),
            "Sender is not Sale Manager or Admin"
        );
        endTime = unixTime;
    }

    function calculateCustomPrice(address prospectiveBuyer, uint discountRate) 
    public requiresUpdate view returns(uint) {
        require(privilgedBuyerList.addressHasCoupon(prospectiveBuyer, discountRate), string(abi.encodePacked(
            "Address ", prospectiveBuyer, " does not have a coupon with a discount rate of ", discountRate, "%")));
        uint price = lastUpdate.price / 100 * (100 - discountRate);
        return price;
    }

    function updateAndCalculateCustomPrice(address prospectiveBuyer, uint discountRate) 
    public pushesUpdate() returns(uint) {
        return calculateCustomPrice(prospectiveBuyer, discountRate);
    }

    function _buyNFTs(uint amount, uint totalPrice) internal {
        usdcEscrowStorageContract.decreaseUsdcBalance(msg.sender, totalPrice);
        for (uint i = 0; i < amount; i++) {
			mintNextNftToAddress(msg.sender);
    	}
		topTime = lastUpdate.time;
	}

    function buyNFT() public pushesUpdate { //requires using existing balance
        uint price = lastUpdate.price;
        _buyNFTs(1, price);
    }

	// needs to be updated to authorize that the applied discounts are approved
    function buyNftsWithDiscounts(uint amount, uint[] memory discountRate) public pushesUpdate {
        uint[] memory prices;
		uint totalPrice;
		for (uint i = 0; i < amount; i++) {
            prices[i] = calculateCustomPrice(msg.sender, discountRate[i]);
			totalPrice += prices[i];
        }
        _buyNFTs(1, totalPrice);
    }

    //caution: only use this if most of the NFTs have been sold. It needs to be tested what is the acceptable
    // upper bound for number of NFTs minted this way before running out of gas.
    function mintRemainderToTreasuryAddress() external pushesUpdate {
        require(
            hasRole(POST_SALE_MINTER_ROLE, _msgSender()) || 
            hasRole(DEFAULT_ADMIN_ROLE, _msgSender()),
            "Sender is not Post-Sale Minter or Admin"
        );
        require(
            block.timestamp > endTime && !lastUpdate.saleIsLive, 
            "Cannot mint to treasury address until sale is finished"
        );
        uint leftToMint = getMaxSupply() - (getNextUnusedToken()-1);
        for (; leftToMint > 0; leftToMint--) {
            mintNextNftToAddress(treasuryAddress);
        }
    }

    function mintNextToTreasuryAddress() public pushesUpdate {
        require(
            hasRole(POST_SALE_MINTER_ROLE, _msgSender()) || 
            hasRole(DEFAULT_ADMIN_ROLE, _msgSender()),
            "Sender is not Post-Sale Minter or Admin"
        );
        require(
            block.timestamp > endTime && !lastUpdate.saleIsLive, 
            "Cannot mint to treasury address until sale is finished"
        );
        uint leftToMint = getMaxSupply() - (getNextUnusedToken()-1);
        require(leftToMint > 0, "No tokens left to mint");
        mintNextNftToAddress(treasuryAddress);
    }

    function mintNextManyToTreasuryAddress(uint numberToMint) public pushesUpdate {
        require(
            hasRole(POST_SALE_MINTER_ROLE, _msgSender()) || 
            hasRole(DEFAULT_ADMIN_ROLE, _msgSender()),
            "Sender is not Post-Sale Minter or Admin"
        );
        require(
            block.timestamp > endTime && !lastUpdate.saleIsLive, 
            "Cannot mint to treasury address until sale is finished"
        );
        uint leftToMint = getMaxSupply() - (getNextUnusedToken()-1);
        leftToMint = Math.min(leftToMint, numberToMint);
        for (; leftToMint > 0; leftToMint--) {
            mintNextNftToAddress(treasuryAddress);
        }
        mintNextNftToAddress(treasuryAddress);
    }
}