//SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.9;

import "hardhat/console.sol";

interface IERC20 {
    function withdraw(uint256 amount) external payable;
    function transfer(address to, uint256 value) external returns (bool);
    function balanceOf(address who) external view returns (uint256);
}

interface IERC20Predicate {
    function startExitWithBurntTokens(bytes calldata data) external;
}

interface IWithdrawManager {
    function processExits(address _token) external;
}

contract EIP1559Burn {
    IERC20 public immutable maticRootToken;
    IERC20 public immutable maticChildToken;
    IERC20Predicate public immutable erc20Predicate;
    IWithdrawManager public immutable withdrawManager;

    constructor() {
        maticRootToken = IERC20(0x7D1AfA7B718fb893dB30A3aBc0Cfc608AaCfeBB0);
        maticChildToken = IERC20(0x0000000000000000000000000000000000001010);
        erc20Predicate = IERC20Predicate(0x158d5fa3Ef8e4dDA8a5367deCF76b94E7efFCe95);
        withdrawManager = IWithdrawManager(0x2A88696e0fFA76bAA1338F2C74497cC013495922);
    }

    modifier onlyRootChain() {
        require(block.chainid == 1, "ONLY_ROOT");
        _;
    }

    modifier onlyChildChain() {
        require(block.chainid == 137, "ONLY_CHILD");
        _;
    }

    function withdraw() external onlyChildChain payable {
        maticChildToken.withdraw{value: msg.value}(msg.value);
    }

    function initiateExit(bytes calldata data) external onlyRootChain {
        erc20Predicate.startExitWithBurntTokens(data);
    }

    function exit() external onlyRootChain {
        withdrawManager.processExits(address(maticRootToken));
        require(
            maticRootToken.transfer(
                address(0),
                maticRootToken.balanceOf(address(this))
        ), "TRANSFER_FAILED");
    }
}
