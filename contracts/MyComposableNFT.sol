pragma solidity ^0.8.0;

// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "./MyERC20.sol";

// TODO: layer in composability for ERC20 tokens based on EIP-998 (Top Down ERC20 specifically)
contract MyComposableNFT is ERC721("MyComposable", "MYC"), MyERC20 {

    // mapping from NFT id to Owner
    mapping(uint => address) NFTidToOwner;

    function mint(address _recipient, uint256 _tokenId) external {
        _mint(_recipient, _tokenId);
    }

    // addFunds function allows owner of NFT to add ERC20s to his NFT
    function addFunds(uint _tokenId, uint _amount) external {
        // validating whether the tokenId matches the owner
        require(NFTidToOwner[_tokenId] == msg.sender, "Not the owner of the NFT");

        mintForNFT(_tokenId, _amount);
    }

    // transfers `_tokenId` from `msg.sender` to `_to`
    function transferNFT(uint _tokenId, address _to) external {
        // validating whether the tokenId matches the owner
        require(NFTidToOwner[_tokenId] == msg.sender, "Not the owner of the NFT");

        _transfer(msg.sender, _to, _tokenId);

        // update the ownership of NFT in the map
        NFTidToOwner[_tokenId] = _to;

    }

    // burns the NFT and transfers the balance of NFT to the owner
    function burnNFT(uint _tokenId) external {
        // validating whether the tokenId matches the owner
        require(NFTidToOwner[_tokenId] == msg.sender, "Not the owner of the NFT");

        _burn(_tokenId);

        // delete the content of mapping corresponding to _tokenId
        delete NFTidToOwner[_tokenId];

        // transfer the ERC20s from contract address to user's address
        transferFunds(_tokenId, msg.sender);
    }
}