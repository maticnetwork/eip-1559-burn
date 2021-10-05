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
        maticRootToken = IERC20(0x499d11E0b6eAC7c0593d8Fb292DCBbF815Fb29Ae);
        maticChildToken = IERC20(0x0000000000000000000000000000000000001010);
        erc20Predicate = IERC20Predicate(0x39c1e715316A1ACBCe0e6438CF62edF83C111975);
        withdrawManager = IWithdrawManager(0x2923C8dD6Cdf6b2507ef91de74F1d5E0F11Eac53);
    }

    modifier onlyRootChain() {
        require(block.chainid == 5, "ONLY_ROOT");
        _;
    }

    modifier onlyChildChain() {
        require(block.chainid == 80001, "ONLY_CHILD");
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
                maticRootToken.balanceOf(address(this)
            )
        ), "TRANSFER_FAILED");
    }
}
