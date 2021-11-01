pragma solidity ^0.8.0;

// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MyERC20 is ERC20("MyERC20", "MYE") {

    // mapping NFT id to it's ERC20 balance
    mapping(uint => uint) balanceOfNFT;

    event updatedBalance(uint256 _tokenId, uint256 _amount);

    function mint(address _recipient, uint256 _amount) external {
        _mint(_recipient, _amount);
    }

    function mintForNFT(uint256 _tokenId, uint256 _amount) internal {
        _mint(address(this), _amount);
        balanceOfNFT[_tokenId] += _amount;
        emit updatedBalance(_tokenId, _amount);
    }

    function transferFunds(uint256 _tokenId, address _owner) internal {
        _transfer(address(this), _owner, _tokenId);
    }
}