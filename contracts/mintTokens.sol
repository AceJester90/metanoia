//SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "./ERC1155MultiUri.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

interface Iowner {
    function owner() external view returns (address);
    function ownerOf(uint id) external view;
    function totalSupply(uint id) external view;
}

contract mintTokens is Ownable, ERC1155MultiUri{

    constructor() ERC1155("") {}

    function viewOwner(address _token, uint _id) public view{
        Iowner(_token).owner();
        Iowner(_token).ownerOf(_id);
        Iowner(_token).totalSupply(_id);
    }

    function viewOwner() public view{
    }

    function mintUniqueNft(address _account,//allow contract owner to mint copy to an address
    uint256 _id,
    bytes memory data,
    string memory _newuri) public onlyOwner{
        uint _amount = 1;
        _mintWithURI(_account, _id, _amount, data, _newuri);
    }

    function mintCopy(address _account,//allow contract owner to mint copy to an address
    uint256 _id,
    bytes memory data) public onlyOwner {
        uint _amount = 1;
        _mintWithoutURI(_account, _id, _amount, data);
    }

    function mintUniqueNftToMultipleAddress(address[] memory _accounts,//allow contract owner to mint new unique nft to multiple addresses
    uint256 _id,
    bytes memory data,
    string memory _newuri) public onlyOwner{
        for(uint i = 0; i < _accounts.length; i++){
            uint _amount = 1;
            _mintWithURI(_accounts[i], _id, _amount, data, _newuri);
        }
    }

    function mintCopyToMultipleAddress(address[] memory _accounts,//allow contract owner to mint copy of a new nft to multiple adresses
    uint256 _id,
    bytes memory data) public onlyOwner{
        for(uint i = 0; i < _accounts.length; i++){
            uint _amount = 1;
            _mintWithoutURI(_accounts[i], _id, _amount, data);
        }
    }

}
