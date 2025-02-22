// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import '@openzeppelin/contracts/token/ERC20/ERC20.sol';
// Uncomment this line to use console.log
// import "hardhat/console.sol";

contract Cowry is ERC20("CowryToken", "CWT"){
    address public owner;

    constructor() {
        owner = msg.sender;
        _mint(msg.sender, 100000e18);
    }

    function mint(uint256 _amount)  external {
        require(msg.sender == owner, "Only owner can mint");
        _mint(owner, _amount);
    }   
}