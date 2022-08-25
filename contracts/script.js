"use strict";

import Web3 from "web3";

const web3 = new Web3(window.ethereum);
await window.ethereum.enable();

const mintToken = web3.eth.Contract(contract_abi, contract_address);

const addresses = [];

function mintUniqueNFTToEachHolder(_id, _data, _newuri) {
  for (let i = 0; i < addresses.length; i++) {
    mintToken.methods.mintUniqueNft.send(addresses[i], _id, _data, _newuri);
  }
}

function mintCopyNFTToEachHolder(_id, _data, _newuri) {
  mintToken.methods.mintUniqueNft.send(addresses[i], _id, _data, _newuri);
  for (let i = 1; i < addresses.length; i++) {
    mintToken.methods.mintCopy.send(addresses[i], _id, _data);
  }
}
