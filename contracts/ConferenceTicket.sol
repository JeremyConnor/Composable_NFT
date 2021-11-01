pragma solidity ^0.8.0;

// SPDX-License-Identifier: MIT

import "./MyComposableNFT.sol";

contract ConferenceTicket {

    // instance of MyComposableNFT contract
    MyComposableNFT myComposableNFT;

    uint256 basePrice = 1 ether;

    uint256 members = 1;

    // can reduce from 256 to lower size.
    uint256 set_composable_contract_address = 0;

    mapping(address => uint256) ethBalance;

    function deployComposableNFT(address _contract) public {
        // this makes the deployComposableNFT function to be called only once.
        require(set_composable_contract_address == 0, "Contract address already set");
        myComposableNFT = MyComposableNFT(_contract);
        set_composable_contract_address = 1;
    }

    function priceFunction(uint256 _memberCount) internal pure returns (uint256) {
        require(_memberCount > 0, "Invalid member count");

        if(_memberCount <= 10) {
            return 10;
        } else if(_memberCount <= 20) {
            return _memberCount;
        } else {
            return 20;
        }
    }

    function checkStandardTicketPrice() public view returns (uint256) {
        return priceFunction(members);
    }

    function checkVIPTicketPrice() public view returns (uint256) {
        return priceFunction(members) + 5;
    }

    function buyStandardTicket() external payable {
        uint256 standardPrice = checkStandardTicketPrice();
        require(msg.value > standardPrice, "Insufficient Ethers");

        payable(address(this)).transfer(standardPrice * basePrice);

        // Token ID = 10 * number of members
        myComposableNFT.mint(msg.sender, members*10);
        // Standard Tickets have 5 Snack Tokens
        myComposableNFT.addFunds(members*10, 5);

        members++;
    }

    function buyVIPTicket() external payable {
        uint256 vipPrice = checkVIPTicketPrice();
        require(msg.value > vipPrice, "Insufficient Ethers");

        payable(address(this)).transfer(vipPrice * basePrice);

        // NFTs are minted to smart contract address and later transferred to 
        // msg.sender after wrapping the VIP ticket.
        // Token ID = 10 * number of members
        myComposableNFT.mint(address(this), members*10);
        // VIP Tickets have 7 Snack Tokens in total
        myComposableNFT.addFunds(members*10, 5);
        // minting new NFT (which will be wrapped inside VIP NFT)
        myComposableNFT.mint(address(this), (members*10)+5);
        myComposableNFT.addFunds((members*10)+5, 2);
        myComposableNFT.wrapNFT(members*10, (members*10)+5);
        myComposableNFT.transferNFT(members*10, msg.sender);

        members++;
    }

}