// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {IERC20} from "../interfaces/IERC20.sol";

contract Vault {

    error ZeroAmount();
    error TransferFailed();
    error NotFactory();
    error InvalidToken();
    error InsufficientBalance();

    address public immutable token;
    address public immutable factory;
    uint256 public totalLiquidity;
    uint256 public creationTime;

    mapping (address => uint256) public balances;


    event Deposit(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);

    constructor (address _token, address _factory) {
        if (_token == address(0)) {
            revert InvalidToken();
        }

        token = _token;
        factory = _factory;
        creationTime = block.timestamp;
    } 

    function deposit(uint256 _amount) external {
        if (amount == 0) {
            revert ZeroAmount();
        }

        bool success = IERC20(token).transferFrom(msg.sender, address(this), _amount);

        if (!success) {
            revert TransferFailed();
        }

        balances[msg.sender] += _amount;
        totalLiquidity += _amount;
        
        emit Deposit(msg.sender, _amount);
    }

    // function withdraw(uint256 amount) external {
    //     if (amount == 0) {
    //         revert ZeroAmount();
    //     }

    //     uint256 userBalance = balances[msg.sender];

    //     if (userBalance < amount) {
    //         revert InsufficientBalance();
    //     }

    //     balances[msg.sender] -= amount;
    //     totalLiquidity -= amount;

    //     bool success = IERC20(token).transfer(msg.sender, amount);

    //     if (!success) {
    //         revert TransferFailed();
    //     }

    //     emit Withdraw(msg.sender, amount);
    // }

    function getTokenBalance() external view returns (uint256) {
        return IERC20(token).balanceOf(address(this));
    }
}