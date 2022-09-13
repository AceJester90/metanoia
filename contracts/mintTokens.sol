//SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

import "./ERC1155MultiUri.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

interface Iowner {
    function totalSupply(uint id) external view returns (uint);
}

contract mintTokens is Ownable, ERC1155MultiUri{
    uint nextFreeId;
    bool success;

    mapping (uint => bool) public locked;

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
    	success = false;
        require(locked[nextFreeId]==false, "This id is locked");
        uint _id = nextFreeId;
        nextFreeId++;
        uint _amount = 1;
        _mintWithURI(_account, _id, _amount, data, _newuri);
        success = true;
    }
    //mint a copy to an address
    function mintCopy(
        address _account,
        uint _id,
        bytes memory data
    ) public onlyOwner {
    	success = false;
        require(locked[_id] == false, "This ID is locked");
        uint _amount = 1;
        _mintWithoutURI(_account, _id, _amount, data);
        success = true;
    }

    //allow contract owner to mint new unique nft to multiple addresses
    function mintUniqueNftsToMultipleAddresses(
        address[] memory _accounts,
        bytes memory data,
        string memory _newuri
    ) public onlyOwner{
        uint _amount = 1;
     	success = false;
        for(uint i = 0; i < _accounts.length; i++){
            require(locked[nextFreeId] == false, "This ID is locked");
            uint _id = nextFreeId;
            nextFreeId++;
            _mintWithURI(_accounts[i], _id, _amount, data, _newuri);
            success = true;
        }
    }

    //allow contract owner to mint copy of a new nft to multiple adresses
    function mintCopiesToMultipleAddresses(
        address[] memory _accounts,
        bytes memory data,
        string memory _newuri
    ) public onlyOwner{
    	success = false;
        require(locked[nextFreeId] == false, "This ID is locked");
        uint _id = nextFreeId;
        nextFreeId++;
        uint _amount = 1;
        _mintWithURI(_accounts[0], _id, _amount, data, _newuri);
        for(uint i = 1; i < _accounts.length; i++){
            _mintWithoutURI(_accounts[i], _id, _amount, data);
        }
        success = true;
    }

    //allow owner to lock a specific ID
    function lockID(uint _id) public onlyOwner{
        require((_id > 0), "This ID can't be locked");
        require(locked[_id] == false, "This ID is already locked");
        locked[_id] = true;
    }
    
    function checkIfLocked(uint _id) external view returns (bool) {
    	bool _locked = locked[_id];
    	return _locked;
    }
    
}
