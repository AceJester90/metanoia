//SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "./ERC1155MultiUri.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

interface Iowner {
    function owner() external view returns (address);
    function ownerOf(uint id) external view;
}

contract mintTokens is Ownable, ERC1155MultiUri{

    constructor() ERC1155("") {}

    function viewOwner(address _token, uint _id) public view{
        Iowner(_token).owner();
        Iowner(_token).ownerOf(_id);
    }

    function mintuniquenft(address _account, uint256 _id, uint256 _amount, bytes memory data, string memory _newuri) public onlyOwner{
        _amount = 1;
        _mintWithURI(_account, _id, _amount, data, _newuri);
    }

    function mintcopy(address _account, uint256 _id, uint256 _amount, bytes memory data) public onlyOwner {
        _amount = 1;
        _mintWithoutURI(_account, _id, _amount, data);
    }

}