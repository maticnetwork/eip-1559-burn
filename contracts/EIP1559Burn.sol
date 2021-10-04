//SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.9;

import "hardhat/console.sol";

interface IERC20Predicate {
    function startExitWithBurntTokens(bytes calldata data) external;
}

interface IERC20 {
    function withdraw(uint256 amount) public payable;
}

contract EIP1159Burn {
    modifier onlyRootChain() {
        require(block.chainid == 5, "ONLY_ROOT");
        _;
    }

    modifier onlyChildChain() {
        require(block.chainid == 80001, "ONLY_CHILD");
        _;
    }

    IERC20Predicate ERC20Predicate;
    IERC20 MaticChildToken;

    constructor() {
        ERC20Predicate = 0x39c1e715316A1ACBCe0e6438CF62edF83C111975;
    }

    function withdraw() external onlyChildChain payable {
        MaticChildToken.withdraw.value(msg.value)(msg.value);
    }

    function initiateExit(bytes calldata data) external onlyRootChain {
        ERC20Predicate.startExitWithBurntTokens(data);
    }

    function exit() external onlyRootChain {

    }
}
