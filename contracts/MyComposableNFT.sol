pragma solidity ^0.8.0;

// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "./MyERC20.sol";

contract MyComposableNFT is ERC721("MyComposable", "MYC") {

    struct Queue {
        uint256[1000] data;
        uint256 front;
        uint256 back;
    }

    // the number of elements stored in the queue.
    function length(Queue memory q) internal pure returns (uint256) {
        return q.back - q.front;
    }

    // the number of elements this queue can hold
    function capacity(Queue memory q) internal pure returns (uint256) {
        return q.data.length - 1;
    }

    // push a new element to the back of the queue
    function push(Queue memory q, uint256 data) internal pure {
        if ((q.back + 1) % q.data.length == q.front)
            return; // throw;
        q.data[q.back] = data;
        q.back = (q.back + 1) % q.data.length;
    }

    // remove and return the element at the front of the queue
    function pop(Queue memory q) internal pure returns (uint256 r) {
        if (q.back == q.front)
            return 0; // throw;
        r = q.data[q.front];
        delete q.data[q.front];
        q.front = (q.front + 1) % q.data.length;
    }

    // instance of MyERC20 contract
    MyERC20 myToken;

    // can reduce from 256 to lower size.
    uint256 set_contract_address = 0;

    // mapping from NFT id to Owner
    mapping(uint256 => address) NFTidToOwner;

    // mapping from container NFT (or the parent NFT) to wrapped NFT (the child NFT)
    // for traversing the tree from root to leaf
    // there can be many wrapped NFTs for a given container NFT, hence using the array
    mapping(uint256 => uint256[]) containerNFTtoWrappedNFT;

    // mapping from wrapped NFT (the child NFT) to container NFT (or the parent NFT)
    // for traversing the tree from leaf to root
    mapping(uint256 => uint256) wrappedNFTtoContainerNFT;

    // mapping from NFT to boolean, to mark the container NFTs
    mapping(uint256 => bool) isContainerNFT;

    function myERC20(address _contract) public {
        // this makes the myERC20 function to be called only once.
        require(set_contract_address == 0, "Contract address already set");
        myToken = MyERC20(_contract);
    }

    // tokenId must be greater than 0;
    function mint(address _recipient, uint256 _tokenId) external {
        require(_tokenId > 0, "Token ID must be greater than 0");

        _mint(_recipient, _tokenId);
        wrappedNFTtoContainerNFT[_tokenId] = 0;
    }

    // addFunds function allows owner of NFT to add ERC20s to his NFT
    function addFunds(uint256 _tokenId, uint256 _amount) external {
        require(_tokenId > 0, "Token ID must be greater than 0");

        // validating whether the tokenId matches the owner
        require(NFTidToOwner[_tokenId] == msg.sender, "Not the owner of the NFT");

        myToken.mintForNFT(_tokenId, _amount);
    }

    // retreive ERC-20 Balance of NFT
    // does not include balance of wrapped NFTs within this NFT
    function getNFTBalance(uint256 _tokenId) external view returns (uint256) {
        require(_tokenId > 0, "Token ID must be greater than 0");
        
        return myToken.retrieveBalance(_tokenId);
    }

    // transfers `_tokenId` from `msg.sender` to `_to`
    // NFT will be transferred only if it is a container NFT and not a wrapped NFT
    function transferNFT(uint256 _tokenId, address _to) external {
        require(_tokenId > 0, "Token ID must be greater than 0");

        // validating whether the tokenId matches the owner
        require(NFTidToOwner[_tokenId] == msg.sender, "Not the owner of the NFT");

        // validating if the NFT is not a wrapped NFT
        require(wrappedNFTtoContainerNFT[_tokenId] == 0, "Cannot transfer wrapped NFT");

        _transfer(msg.sender, _to, _tokenId);

        // update the ownership of NFT in the map
        NFTidToOwner[_tokenId] = _to;

    }

    // wrapNFT function wraps an NFT inside a container NFT
    function wrapNFT(uint256 _containerNFT, uint256 _wrappedNFT) external {
        require(_containerNFT > 0, "Token ID must be greater than 0");
        require(_wrappedNFT > 0, "Token ID must be greater than 0");

        // If a wrappedNFT is containerNFT then the tree like structure will form a loop.
        require(!isContainerNFT[_wrappedNFT], "The NFT you are trying to wrap is already a container NFT");

        // msg.sender must be the owner of both container and wrapped NFTs
        require(NFTidToOwner[_containerNFT] == msg.sender, "You are not the owner of the container NFT");
        require(NFTidToOwner[_wrappedNFT] == msg.sender, "You are not the owner of the wrapped NFT");

        containerNFTtoWrappedNFT[_containerNFT].push(_wrappedNFT);
        wrappedNFTtoContainerNFT[_wrappedNFT] = _containerNFT;

        // Since the container NFT already knows it's owner, there is no need to save 
        // the same information with the wrapped NFT.
        delete NFTidToOwner[_wrappedNFT];

    }

    // getWrappedNFTs function returns all the NFTs wrapped in a given container NFT
    function getWrappedNFTs(uint256 _containerNFT) external view returns (uint256 [] memory) {
        require(_containerNFT > 0, "Token ID must be greater than 0");
        
        return containerNFTtoWrappedNFT[_containerNFT];
    }

    // function to retreive container NFT of a given wrapped NFT
    function getContainerNFT(uint256 _wrappedNFT) external view returns (uint256) {
        require(_wrappedNFT > 0, "Token ID must be greater than 0");

        return wrappedNFTtoContainerNFT[_wrappedNFT];
    }

    // getOwnerOfNFT returns the owner of the NFT regardless of the fact that
    // NFTs can be container NFT or wrapped NFT
    function getOwnerOfNFT(uint256 _tokenId) external view returns (address) {
        require(_tokenId > 0, "Token ID must be greater than 0");

        while(_tokenId > 0) {
            _tokenId = wrappedNFTtoContainerNFT[_tokenId];
        }

        return NFTidToOwner[_tokenId];

    }

    // bfsTraversal is used to traverse through tree like sturcutre of NFTs.
    // Number of NFTs wrapped within a container NFT should not be more than 1000
    // Because, maximum allowed size of NFT is fixed to be 1000
    function bfsTraversal(uint256 _root) internal view returns (uint256 [] memory) {
        Queue memory q;
        push(q, _root);

        uint256[] memory listOfNFT;
        uint256 i = 0;

        while(length(q) > 0) {
            uint256 _node = pop(q);
            listOfNFT[i] = _node;
            i++;

            uint256 len = containerNFTtoWrappedNFT[_node].length;
            
            while(len > 0) {
                push(q, containerNFTtoWrappedNFT[_node][len]);
                len--;
            }
        }

        return listOfNFT;
    }

    // burns the NFT and transfers the balance of NFT to the owner
    // this will also burn all the wrapped NFTs within this NFT
    function burnNFT(uint256 _tokenId) external {
        require(_tokenId > 0, "Token ID must be greater than 0");

        // validating whether the tokenId matches the owner
        require(NFTidToOwner[_tokenId] == msg.sender, "Not the owner of the NFT");

        uint256[] memory listOfNFT = bfsTraversal(_tokenId);

        // delete the content of mapping corresponding to _tokenId
        delete NFTidToOwner[_tokenId];

        for(uint256 i=0; i<listOfNFT.length; i++) {
            _burn(_tokenId);

            // transfer the ERC20s from contract address to user's address
            myToken.transferFunds(_tokenId, msg.sender);

            delete wrappedNFTtoContainerNFT[i];
            delete containerNFTtoWrappedNFT[i];
        }
        
    }

}