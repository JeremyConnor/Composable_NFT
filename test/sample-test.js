const { expect } = require("chai");
const { ethers } = require("hardhat");

/*
describe("Greeter", function () {
  
Greeter.sol contract
//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";

contract Greeter {
    string private greeting;

    constructor(string memory _greeting) {
        console.log("Deploying a Greeter with greeting:", _greeting);
        greeting = _greeting;
    }

    function greet() public view returns (string memory) {
        return greeting;
    }

    function setGreeting(string memory _greeting) public {
        console.log("Changing greeting from '%s' to '%s'", greeting, _greeting);
        greeting = _greeting;
    }
}
  it("Should return the new greeting once it's changed", async function () {
    const Greeter = await ethers.getContractFactory("Greeter");
    const greeter = await Greeter.deploy("Hello, world!");
    await greeter.deployed();

    expect(await greeter.greet()).to.equal("Hello, world!");

    const setGreetingTx = await greeter.setGreeting("Hola, mundo!");

    // wait until the transaction is mined
    await setGreetingTx.wait();

    expect(await greeter.greet()).to.equal("Hola, mundo!");
  });
});
*/

describe("MyERC20.sol", function () {
  it("Should do something", async function () {
    const MyERC20 = await ethers.getContractFactory("MyERC20");
    const myERC20 = await MyERC20.deploy();

    await myERC20.deployed();

  });
});

describe("MyERC20.sol", function () {
  it("Should deploy contracts and check functions", async function () {
    const [owner, addr1, addr2] = await ethers.getSigners();

    const MyERC20 = await ethers.getContractFactory("MyERC20");
    const myERC20 = await MyERC20.deploy();

    await myERC20.deployed();
    const myERC20_address = myERC20.address;

    const MyComposableNFT = await ethers.getContractFactory("MyComposableNFT");
    const myComposableNFT = await MyComposableNFT.deploy();

    await myComposableNFT.deployed();
    const myComposableNFT_address = myComposableNFT.address;

    console.log("myERC20 contract address : ", myERC20_address);

    console.log("myComposableNFT contract address : ", myComposableNFT_address);

    await myComposableNFT.myERC20(myERC20_address);
    console.log("Set Contract address");

    await myComposableNFT.mint(owner.address, 1);
    console.log("Minted");
  
  });
});