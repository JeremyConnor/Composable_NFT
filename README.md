# Stretch Goal 1 : Composable NFTs that can also contain NFTs
This project is an attempt to create composable NFTs. Composable NFTs are the ERC-721 tokens which can hold ERC-20 and even ERC-721 tokens. In this project, the NFTs are desgined to hold both ERC-20 and multiple ERC-721 tokens.

Throughout the project a parent NFT is referred to as container NFT and the NFTs stored within this container NFT i.e. the child NFTs are referred to as wrapped NFTs.

## Properties of Composable NFTs containing NFTs :
* Each container NFT can have ERC-20 tokens and more than one wrapped NFTs,
* Every NFT must have a single immediate container NFT,
* None of the wrapped NFT can be transferred (i.e. only the root NFT can be transferred)
* Burning a particular NFT will decompose all the wrapped NFTs within it, and transfer the
ERC-20 token of this NFT to the owner. Owner will also get all the constituent wrapped NFTs
as an individual NFT without loosing their property.

## Using the MyComposableNFT
1) User can call `mint` function to mint a new composable NFT.
2) User can call `addFunds` function to add balance to the NFT.
3) User can call `wrapNFT` function to wrap NFT that he owns within another of his NFT.
4) User can call `getWrappedNFTs` function to get list of all the NFTs wrapped within a particular NFT.
5) User can call `getContainerNFT` function to get the container of a particular wrapped NFT.
6) User can call `getOwnerOfNFT` function to get the owner of any NFT.
3) User can call `transferNFT` function to transfer NFT to other eth addresses.
4) User can call `burnNFT` function to burn the container NFT and redeem all the ERC-20 and constituent ERC-721 tokens to his own eth address.

## Approach
From the idea of NFT being stored inside an NFT, the first thing that comes to my mind is a tree.
Since it is a tree, therefore, I had to also write Breadth First Search and use Queue for traversal of the tree like structure. It took some time to finalise the property of composable NFT, but once it was clear, all that was left was the code.
