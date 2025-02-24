// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/Stake.sol";

contract StakingPoolTest is Test {
    StakingPool stakingPool;
    address owner = address(0x123);
    address user = address(0x456);
    address stakingToken = address(0x789);

    function setUp() public {
        vm.prank(owner);
        stakingPool = new StakingPool(stakingToken, owner);
    }

    function testCreatePool() public {
        vm.prank(owner);
        stakingPool.createPool(1e16);
        assertEq(stakingPool.poolCount(), 1);
    }

    function testStake() public {
        vm.prank(owner);
        stakingPool.createPool(1e16);

        vm.prank(user);
        stakingPool.stake(1, 100e18);

        (uint256 amount, ) = stakingPool.stakers(1, user);
        assertEq(amount, 100e18);
    }

    function testUnstake() public {
        vm.prank(owner);
        stakingPool.createPool(1e16);

        vm.prank(user);
        stakingPool.stake(1, 100e18);

        vm.warp(block.timestamp + 100); 

        vm.prank(user);
        stakingPool.unstake(1);

        (uint256 amount, ) = stakingPool.stakers(1, user);
        assertEq(amount, 0);
    }
}