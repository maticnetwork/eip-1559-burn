//SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/utils/Create2.sol";
import "./EIP1559Burn.sol";

contract Deployer {
	constructor(
		IERC20 _maticRootToken,
        IERC20Predicate _erc20Predicate,
        IWithdrawManager _withdrawManager,
        uint24 _rootChainId,
        uint24 _childChainId,
        bytes32 _salt
        ) payable {
		bytes memory bytecode = abi.encodePacked(
			type(EIP1559Burn).creationCode,
			abi.encode(_maticRootToken, _erc20Predicate, _withdrawManager, _rootChainId, _childChainId)
		);
		Create2.deploy(msg.value, _salt, bytecode);
	}
}
