//SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

import "./ERC1155MultiUri.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

interface Iowner {
    function totalSupply(uint id) external view returns (uint);
}

contract mintTokens is Ownable, ERC1155MultiUri{
    uint nextFreeId;

    mapping (uint => bool) public lock;

    constructor() ERC1155("") {}

    //view total supply of the given token 
    function viewTotalSupply(address _token, uint _id) public view{
        Iowner(_token).totalSupply(_id);
    }

    //mint unique nft to an address
    function mintUniqueNft(
        address _account,
        bytes memory data,
        string memory _newuri
    ) public onlyOwner{
        require(lock[nextFreeId]==false, "This id is locked");
        uint _id = nextFreeId;
        nextFreeId++;
        uint _amount = 1;
        _mintWithURI(_account, _id, _amount, data, _newuri);
    }
    //mint a copy to an address
    function mintCopy(
        address _account,
        bytes memory data
    ) public onlyOwner {
        require(lock[nextFreeId] == false, "This ID is locked");
        uint _id = nextFreeId;
        nextFreeId++;
        uint _amount = 1;
        _mintWithoutURI(_account, _id, _amount, data);
    }

    //allow contract owner to mint new unique nft to multiple addresses
    function mintUniqueNftsToMultipleAddresses(
        address[] memory _accounts,
        bytes memory data,
        string memory _newuri
    ) public onlyOwner{
        uint _amount = 1;
        for(uint i = 0; i < _accounts.length; i++){
            require(lock[nextFreeId] == false, "This ID is locked");
            uint _id = nextFreeId;
            nextFreeId++;
            _mintWithURI(_accounts[i], _id, _amount, data, _newuri);
        }
    }

    //allow contract owner to mint copy of a new nft to multiple adresses
    function mintCopiesToMultipleAddresses(
        address[] memory _accounts,
        bytes memory data,
        string memory _newuri
    ) public onlyOwner{
        require(lock[nextFreeId] == false, "This ID is locked");
        uint _id = nextFreeId;
        nextFreeId++;
        uint _amount = 1;
        _mintWithURI(_accounts[0], _id, _amount, data, _newuri);
        for(uint i = 1; i < _accounts.length; i++){
            _mintWithoutURI(_accounts[i], _id, _amount, data);
        }
    }

    //allow owner to lock a specific ID
    function lockID(uint _id) public onlyOwner{
        require(lock[_id] == false, "This ID is already locked");
        require((_id > 0), "This ID can't be locked");
        lock[_id] = true;
    }

    /*function mintCopiesOfNewNftToEachCurrentHolder(
        address _token,
        bytes memory data,
        string memory _newuri
    ) public onlyOwner{
        require(lock[_id] == false, "This ID is locked");
        address[] memory _accounts = Iowner(_token).owners();
        mintCopiesToMultipleAddresses(_accounts, data, _newuri);
    }

    function mintUniqueNftsToEachCurrentHolder(
        address _token,
        bytes memory data,
        string memory _newuri
    ) public onlyOwner{
        require(lock[_id] == false, "This ID is locked");
        address[] memory _accounts = Iowner(_token).owners();
        mintUniqueNftsToMultipleAddresses(_accounts, data, _newuri);
    }
    */
}
