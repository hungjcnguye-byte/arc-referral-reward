// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract ReferralReward {
    IERC20 public immutable usdc;
    address public owner;
    uint256 public rewardAmount = 5 * 1e6; // 5 USDC

    mapping(address => address) public referredBy;
    mapping(address => uint256) public referralCount;
    mapping(address => bool) public registered;

    event Registered(address indexed user, address indexed referrer);
    event RewardPaid(address indexed referrer, address indexed referee, uint256 amount);

    constructor(address _usdc) {
        require(_usdc != address(0), "BAD_USDC");
        usdc = IERC20(_usdc);
        owner = msg.sender;
    }

    modifier onlyOwner() { require(msg.sender == owner, "NOT_OWNER"); _; }

    function register(address referrer) external {
        require(!registered[msg.sender], "ALREADY_REG");
        require(referrer != msg.sender && referrer != address(0), "BAD_REFERRER");
        registered[msg.sender] = true;
        referredBy[msg.sender] = referrer;
        referralCount[referrer]++;

        uint256 bal = usdc.balanceOf(address(this));
        if (bal >= rewardAmount * 2) {
            usdc.transfer(referrer, rewardAmount);
            usdc.transfer(msg.sender, rewardAmount);
            emit RewardPaid(referrer, msg.sender, rewardAmount);
        }
        emit Registered(msg.sender, referrer);
    }

    function setReward(uint256 amount) external onlyOwner { rewardAmount = amount; }
    function fund(uint256 amount) external { /* just send USDC to contract */ }
}
