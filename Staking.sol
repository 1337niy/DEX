// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract Staking is Ownable {
    using SafeMath for uint256;

    // Токен, который стейкают (LP-токен)
    IERC20 public stakingToken;
    // Токен вознаграждения
    IERC20 public rewardToken;

    // Время начала стейкинга
    uint256 public startTime;
    // Время окончания стейкинга
    uint256 public endTime;
    // Общее количество вознаграждений
    uint256 public totalRewards;
    // Вознаграждение за блок
    uint256 public rewardPerBlock;

    // Информация о стейкерах
    struct StakerInfo {
        uint256 amount; // Количество застейканных токенов
        uint256 rewardDebt; // Долг по вознаграждениям
    }

    // Маппинг стейкеров
    mapping(address => StakerInfo) public stakers;

    // Аккумулированное вознаграждение на токен
    uint256 public accRewardPerShare;
    // Общее количество застейканных токенов
    uint256 public totalStaked;

    // События
    event Staked(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event RewardPaid(address indexed user, uint256 reward);

    constructor(
        address _stakingToken,
        address _rewardToken,
        uint256 _startTime,
        uint256 _endTime,
        uint256 _totalRewards
    ) {
        stakingToken = IERC20(_stakingToken);
        rewardToken = IERC20(_rewardToken);
        startTime = _startTime;
        endTime = _endTime;
        totalRewards = _totalRewards;
        rewardPerBlock = totalRewards / (endTime - startTime);
    }

    // Функция для стейкинга токенов
    function stake(uint256 _amount) external {
        require(block.timestamp >= startTime, "Staking: Staking not started");
        require(block.timestamp < endTime, "Staking: Staking ended");
        require(_amount > 0, "Staking: Cannot stake 0");

        _updatePool();

        if (stakers[msg.sender].amount > 0) {
            uint256 pending = stakers[msg.sender].amount.mul(accRewardPerShare).div(1e18).sub(stakers[msg.sender].rewardDebt);
            if (pending > 0) {
                rewardToken.transfer(msg.sender, pending);
                emit RewardPaid(msg.sender, pending);
            }
        }

        stakingToken.transferFrom(msg.sender, address(this), _amount);
        stakers[msg.sender].amount = stakers[msg.sender].amount.add(_amount);
        totalStaked = totalStaked.add(_amount);
        stakers[msg.sender].rewardDebt = stakers[msg.sender].amount.mul(accRewardPerShare).div(1e18);

        emit Staked(msg.sender, _amount);
    }

    // Функция для вывода стейка
    function withdraw(uint256 _amount) external {
        require(_amount > 0, "Staking: Cannot withdraw 0");
        require(stakers[msg.sender].amount >= _amount, "Staking: Insufficient staked amount");

        _updatePool();

        uint256 pending = stakers[msg.sender].amount.mul(accRewardPerShare).div(1e18).sub(stakers[msg.sender].rewardDebt);
        if (pending > 0) {
            rewardToken.transfer(msg.sender, pending);
            emit RewardPaid(msg.sender, pending);
        }

        stakingToken.transfer(msg.sender, _amount);
        stakers[msg.sender].amount = stakers[msg.sender].amount.sub(_amount);
        totalStaked = totalStaked.sub(_amount);
        stakers[msg.sender].rewardDebt = stakers[msg.sender].amount.mul(accRewardPerShare).div(1e18);

        emit Withdrawn(msg.sender, _amount);
    }

    // Функция для получения вознаграждений
    function getReward() external {
        _updatePool();

        uint256 pending = stakers[msg.sender].amount.mul(accRewardPerShare).div(1e18).sub(stakers[msg.sender].rewardDebt);
        if (pending > 0) {
            rewardToken.transfer(msg.sender, pending);
            emit RewardPaid(msg.sender, pending);
        }

        stakers[msg.sender].rewardDebt = stakers[msg.sender].amount.mul(accRewardPerShare).div(1e18);
    }

    // Внутренняя функция для обновления пула
    function _updatePool() internal {
        if (block.timestamp <= startTime) {
            return;
        }

        if (totalStaked == 0) {
            return;
        }

        uint256 multiplier = _getMultiplier();
        uint256 reward = multiplier.mul(rewardPerBlock);
        accRewardPerShare = accRewardPerShare.add(reward.mul(1e18).div(totalStaked));
    }

    // Внутренняя функция для получения множителя
    function _getMultiplier() internal view returns (uint256) {
        if (block.timestamp <= startTime) {
            return 0;
        }
        if (block.timestamp >= endTime) {
            return endTime - startTime;
        }
        return block.timestamp - startTime;
    }

    // Функция для просмотра pending rewards
    function pendingReward(address _user) external view returns (uint256) {
        if (totalStaked == 0) {
            return 0;
        }

        uint256 accRewardPerShareTemp = accRewardPerShare;
        uint256 multiplier = _getMultiplier();
        uint256 reward = multiplier.mul(rewardPerBlock);
        accRewardPerShareTemp = accRewardPerShareTemp.add(reward.mul(1e18).div(totalStaked));

        return stakers[_user].amount.mul(accRewardPerShareTemp).div(1e18).sub(stakers[_user].rewardDebt);
    }
}
