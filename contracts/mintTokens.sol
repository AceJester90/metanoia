//SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

import "./ERC1155MultiUri.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

interface Iowner {
    function owners() external view returns (address[] memory);
    function ownerOf(uint id) external view returns (address);
    function totalSupply(uint id) external view returns (uint);
}

contract mintTokens is Ownable, ERC1155MultiUri{

    uint nextFreeId;

    constructor() ERC1155("") {}

    //view the owner/owners and the total supply of an specific ID nft
    function viewOwner(address _token, uint _id) public view{
        Iowner(_token).ownerOf(_id);
    }

    //view total supply of the given token 
    function viewTotalSupply(address _token, uint _id) public view{
        Iowner(_token).totalSupply(_id);
    }
    
    //view all Mixie Holders
    function viewOwners(address _token) public view{
        Iowner(_token).owners();
    }

    //allow contract owner to mint copy to an address P.S Change to internal before submitting to mainnet
    function mintUniqueNft(
        address _account,
        uint256 _id,
        bytes memory data,
        string memory _newuri
    ) public onlyOwner{
        uint _amount = 1;
        _mintWithURI(_account, _id, _amount, data, _newuri);
    }

    //allow contract owner to mint copy to an address P.S Change to internal before submitting to mainnet
    function mintCopy(
        address _account,
        uint256 _id,
        bytes memory data
    ) public onlyOwner {
        uint _amount = 1;
        _mintWithoutURI(_account, _id, _amount, data);
    }

    //allow contract owner to mint new unique nft to multiple addresses
    function mintUniqueNftToMultipleAddress(
        address[] memory _accounts,
        bytes memory data,
        string memory _newuri
    ) public onlyOwner{
        uint _amount = 1;
        for(uint i = 0; i < _accounts.length; i++){
            uint _id = nextFreeId;
            nextFreeId++;
            _mintWithURI(_accounts[i], _id, _amount, data, _newuri);
        }
    }

    //allow contract owner to mint copy of a new nft to multiple adresses
    function mintCopyToMultipleAddress(
        address[] memory _accounts,
        bytes memory data,
        string memory _newuri
    ) public onlyOwner{
        uint _id = nextFreeId;
        nextFreeId++;
        uint _amount = 1;
        _mintWithURI(_accounts[0], _id, _amount, data, _newuri);
        for(uint i = 0; i < _accounts.length; i++){
            _mintWithoutURI(_accounts[i+1], _id, _amount, data);
        }
    }
}
