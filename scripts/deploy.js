require("dotenv").config();
const config = require("../config.json");
const hre = require("hardhat");

async function main() {
  let maticRootToken, withdrawManagerProxy, childChainId, rootChainId;

  const network = await hre.ethers.provider.getNetwork();

  if (network.chainId === 1 || network.chainId === 137) {
    // Ethereum Mainnet
    maticRootToken = config.mainnet.maticRootToken.address;
    withdrawManagerProxy = config.mainnet.withdrawManagerProxy.address;
    rootChainId = config.mainnet.rootChainId;
    childChainId = config.mainnet.childChainId;
  } else if (network.chainId === 5 || network.chainId === 80001) {
    // Goerli Testnet
    maticRootToken = config.testnet.maticRootToken.address;
    withdrawManagerProxy = config.testnet.withdrawManagerProxy.address;
    rootChainId = config.testnet.rootChainId;
    childChainId = config.testnet.childChainId;
  } else {
    maticRootToken = process.env.MATIC_ROOT_TOKEN;
    withdrawManagerProxy = process.env.WITHDRAW_MANAGER_PROXY;
    rootChainId = process.env.ROOT_CHAINID;
    childChainId = process.env.CHILD_CHAINID;
  }

  const EIP1559Burn = await hre.ethers.getContractFactory("EIP1559Burn");
  const eip1559Burn = await EIP1559Burn.deploy(
    maticRootToken,
    withdrawManagerProxy,
    rootChainId,
    childChainId
  );
  console.log(eip1559Burn);

  await eip1559Burn.deployed();

  console.log(
    "EIP1559Burn deployed to:",
    eip1559Burn.address,
    "Chain ID:",
    network.chainId
  );

  console.log(
    eip1559Burn.address,
    maticRootToken,
    withdrawManagerProxy,
    rootChainId,
    childChainId
  ); // Makes hardhat etherscan verifications much easier!
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
