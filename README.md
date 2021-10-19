# EIP 1559 Burn
These contracts are for implementing the EIP-1559 burn mechanism on the Polygon mainnet and Mumbai testnet. It uses
Polygon Plasma implementations to batch-transfer and batch-burn MATIC ERC-20 tokens on the Ethereum mainnet and
Goerli testnet, respectively.

## How does it work?
The same contract is deployed on both chains at the same address. This can be done using `CREATE` by having
the same nonce on an EOA, or using the `Deployer` contract to deploy deterministically using `CREATE2`.
* Deposit native gas token (MRC20) to the contract on the chain child
* Call the contract's `withdraw()` function to trigger a withdrawal to the root chain (the withdrawal is performed
in the contract's context)
* Submit the `withdraw()` transaction proof to the contract on the root chain, on the `initiateExit()` function with the
appropriate plasma predicate
* Wait for the exit period (7 days for mainnet)
* Call the `exit()` function with enough gas (> 370k) and the contract will perform the exit for the tokens and transfer
them to `0x...dead` (MATIC ERC-20 is not burnable).
