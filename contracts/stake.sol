// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract StakingContract is Ownable {
    struct StakingData {
        uint256 stakedAmount;
        uint256 stakingTime;
    }

    uint256 public totalStaked;
    uint256 public lastUpdateTime;
    uint256 public rewardPerSecond;

    mapping(address => StakingData) public stakingData;

    IERC20 public stakingToken;
    IERC20 public rewardToken;

    event Staked(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event RewardDistributed(uint256 amount);

    constructor(address _stakingToken, address _rewardToken) {
        stakingToken = IERC20(_stakingToken);
        rewardToken = IERC20(_rewardToken);
    }

    function calculateReward() public view returns (uint256) {
        uint256 timeElapsed = block.timestamp - lastUpdateTime;
        return totalStaked * timeElapsed * rewardPerSecond;
    }

    function stake(uint256 amount) external {
        require(amount > 0, "Cannot stake 0 tokens");

        uint256 stakedAmount = stakingData[msg.sender].stakedAmount;
        if (stakedAmount > 0) {
            uint256 reward = calculateReward();
            if (reward > 0) {
                require(rewardToken.transfer(msg.sender, reward), "Reward transfer failed");
                emit RewardDistributed(reward);
            }
        }

        require(stakingToken.transferFrom(msg.sender, address(this), amount), "Token transfer failed");

        stakingData[msg.sender].stakedAmount += amount;
        stakingData[msg.sender].stakingTime = block.timestamp;

        totalStaked += amount;

        emit Staked(msg.sender, amount);
    }

    function withdraw() external {
        uint256 stakedAmount = stakingData[msg.sender].stakedAmount;
        require(stakedAmount > 0, "Cannot withdraw 0 tokens");

        uint256 reward = calculateReward();
        if (reward > 0) {
            require(rewardToken.transfer(msg.sender, reward), "Reward transfer failed");
            emit RewardDistributed(reward);
        }

        require(stakingToken.transfer(msg.sender, stakedAmount), "Token transfer failed");

        stakingData[msg.sender].stakedAmount = 0;
        stakingData[msg.sender].stakingTime = 0;

        totalStaked -= stakedAmount;

        emit Withdrawn(msg.sender, stakedAmount);
    }

    function distributeReward() external onlyOwner {
        uint256 rewardAmount = calculateReward();
        require(rewardAmount > 0, "No reward to distribute");

        uint256 remainingReward = rewardAmount;

        for (uint256 i = 0; i < stakers.length; i++) {
            address staker = stakers[i];
            uint256 reward = calculateUserReward(staker);
            remainingReward -= reward;
            require(remainingReward >= 0, "Error: remainingReward should be greater than or equal to 0");

            require(rewardToken.transfer(staker, reward), "Reward transfer failed");
        }

        require(rewardToken.transfer(msg.sender, remainingReward), "Reward transfer to owner failed");

        lastUpdateTime = block.timestamp;
        emit RewardDistributed(rewardAmount);
    }

    function calculateUserReward(address staker) public view returns (uint256) {
        StakingData memory staking = stakingData[staker];
        uint256 timeElapsed = block.timestamp - staking.stakingTime;
        uint256 stakedAmount = staking.stakedAmount;
        return stakedAmount * timeElapsed * rewardPerSecond;
    }

}