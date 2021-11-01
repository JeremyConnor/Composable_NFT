pragma solidity ^0.8.0;

// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "./MyERC20.sol";

// TODO: layer in composability for ERC20 tokens based on EIP-998 (Top Down ERC20 specifically)
contract MyComposableNFT is ERC721("MyComposable", "MYC") {

    // instance of MyERC20 contract
    MyERC20 myToken;

    // can reduce from 256 to lower size.
    uint256 set_contract_address = 0;

    // mapping from NFT id to Owner
    mapping(uint256 => address) NFTidToOwner;

    function myERC20(address _contract) public {
        // this makes the myERC20 function to be called only once.
        require(set_contract_address == 0, "Contract address already set");
        myToken = MyERC20(_contract);
        set_contract_address = 1;
    }

    function mint(address _recipient, uint256 _tokenId) external {
        _mint(_recipient, _tokenId);
    }

    // addFunds function allows owner of NFT to add ERC20s to his NFT
    function addFunds(uint256 _tokenId, uint256 _amount) external {
        // validating whether the tokenId matches the owner
        require(NFTidToOwner[_tokenId] == msg.sender, "Not the owner of the NFT");

        myToken.mintForNFT(_tokenId, _amount);
    }

    // retreive ERC-20 Balance of NFT
    function getNFTBalance(uint256 _tokenId) external view returns (uint256) {
        return myToken.retrieveBalance(_tokenId);
    }

    // transfers `_tokenId` from `msg.sender` to `_to`
    function transferNFT(uint256 _tokenId, address _to) external {
        // validating whether the tokenId matches the owner
        require(NFTidToOwner[_tokenId] == msg.sender, "Not the owner of the NFT");

        _transfer(msg.sender, _to, _tokenId);

        // update the ownership of NFT in the map
        NFTidToOwner[_tokenId] = _to;

    }

    // burns the NFT and transfers the balance of NFT to the owner
    function burnNFT(uint256 _tokenId) external {
        // validating whether the tokenId matches the owner
        require(NFTidToOwner[_tokenId] == msg.sender, "Not the owner of the NFT");

        _burn(_tokenId);

        // delete the content of mapping corresponding to _tokenId
        delete NFTidToOwner[_tokenId];

        // transfer the ERC20s from contract address to user's address
        myToken.transferFunds(_tokenId, msg.sender);
    }
}