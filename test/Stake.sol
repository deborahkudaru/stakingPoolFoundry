// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract StakingPool is Ownable {
    struct Pool {
        uint256 rewardPercentage; // Reward percentage per second (in wei)
        uint256 totalStaked;
        uint256 createdAt;
    }

    struct Staker {
        uint256 amount;
        uint256 stakedAt;
    }

    IERC20 public stakingToken;

    mapping(uint256 => Pool) public pools;
    mapping(uint256 => mapping(address => Staker)) public stakers;
    uint256 public poolCount;

    event PoolCreated(uint256 poolId, uint256 rewardPercentage);
    event Staked(address indexed user, uint256 poolId, uint256 amount);
    event Unstaked(address indexed user, uint256 poolId, uint256 amount, uint256 reward);

    constructor(address _stakingToken) {
        stakingToken = IERC20(_stakingToken);
    }

    function createPool(uint256 _rewardPercentage) external onlyOwner {
        poolCount++;
        pools[poolCount] = Pool({
            rewardPercentage: _rewardPercentage,
            totalStaked: 0,
            createdAt: block.timestamp
        });

        emit PoolCreated(poolCount, _rewardPercentage);
    }

    function stake(uint256 _poolId, uint256 _amount) external {
        require(_poolId > 0 && _poolId <= poolCount, "Invalid pool ID");
        require(_amount > 0, "Amount must be greater than 0");

        Pool storage pool = pools[_poolId];
        Staker storage staker = stakers[_poolId][msg.sender];

        if (staker.amount > 0) {
            uint256 reward = calculateReward(_poolId, msg.sender);
            stakingToken.transfer(msg.sender, reward);
        }

        stakingToken.transferFrom(msg.sender, address(this), _amount);
        staker.amount += _amount;
        staker.stakedAt = block.timestamp;
        pool.totalStaked += _amount;

        emit Staked(msg.sender, _poolId, _amount);
    }

    function unstake(uint256 _poolId) external {
        require(_poolId > 0 && _poolId <= poolCount, "Invalid pool ID");

        Pool storage pool = pools[_poolId];
        Staker storage staker = stakers[_poolId][msg.sender];

        require(staker.amount > 0, "No staked amount");

        uint256 reward = calculateReward(_poolId, msg.sender);
        uint256 totalAmount = staker.amount + reward;

        stakingToken.transfer(msg.sender, totalAmount);
        pool.totalStaked -= staker.amount;
        staker.amount = 0;
        staker.stakedAt = 0;

        emit Unstaked(msg.sender, _poolId, staker.amount, reward);
    }

    function calculateReward(uint256 _poolId, address _user) public view returns (uint256) {
        Staker memory staker = stakers[_poolId][_user];
        if (staker.amount == 0) return 0;

        Pool memory pool = pools[_poolId];
        uint256 stakingDuration = block.timestamp - staker.stakedAt;
        uint256 reward = (staker.amount * pool.rewardPercentage * stakingDuration) / 1e18;

        return reward;
    }
}