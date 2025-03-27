# Decentralized Exchange (DEX) with Staking

This repository contains a set of Solidity smart contracts implementing a Decentralized Exchange (DEX) with an Automated Market Maker (AMM) mechanism and a staking feature for liquidity providers. The project demonstrates the creation of ERC-20 tokens, liquidity pools, token swapping, and a staking system to reward users with additional tokens.

## Project Overview

The goal of this project is to showcase blockchain development skills by building a functional DEX similar to Uniswap, enhanced with a staking mechanism. The contracts are written in Solidity and utilize OpenZeppelin libraries for security and standard compliance.

### Key Features
- **Token Creation**: Deploy custom ERC-20 tokens with minting and burning capabilities.
- **Liquidity Pools**: Create and manage liquidity pools for token pairs.
- **Token Swapping**: Swap tokens using an AMM model with constant product formula (`x * y = k`).
- **Liquidity Management**: Add and remove liquidity with LP token issuance.
- **Staking**: Stake LP tokens to earn rewards in a separate reward token.

### Smart Contracts
1. **`Token.sol`**: Implements an ERC-20 token with minting and burning functionality.
2. **`Factory.sol`**: Creates new liquidity pool pairs and tracks them.
3. **`Pair.sol`**: Manages liquidity pools, including adding/removing liquidity and swapping tokens.
4. **`Router.sol`**: Simplifies user interactions with pools (liquidity management and swaps).
5. **`Staking.sol`**: Allows staking LP tokens to earn rewards over a defined period.

## Prerequisites

- **Node.js** and **npm**: For installing dependencies.
- **Hardhat** or **Truffle**: For compiling, testing, and deploying contracts.
- **MetaMask**: For interacting with the deployed contracts in a testnet.
- **Ethereum Testnet**: Such as Rinkeby, Sepolia, or a local network like Hardhat Network.

## Installation

1. **Clone the repository**:
   ```bash
   git clone https://github.com/1337niy/DEX.git
   cd your-repo-name

2. Install dependencies:
   npm install
   npm install @openzeppelin/contracts

3. Set up Hardhat (optional, if using Hardhat):
   npx hardhat
   Follow the prompts to create a basic Hardhat project.

4. Configure environment: Create a .env file in the root directory with the following:
   PRIVATE_KEY=your-private-key
   INFURA_API_KEY=your-infura-api-key
   ETHERSCAN_API_KEY=your-etherscan-api-key
   Update hardhat.config.js to use these variables:
   require("@nomicfoundation/hardhat-toolbox");
   require("dotenv").config();

   module.exports = {
     solidity: "0.8.0",
     networks: {
       sepolia: {
         url: `https://sepolia.infura.io/v3/${process.env.INFURA_API_KEY}`,
         accounts: [process.env.PRIVATE_KEY]
       }
     },
     etherscan: {
       apiKey: process.env.ETHERSCAN_API_KEY
     }
   };

## Deployment

1. Compile contracts:
   npx hardhat compile

2. Deploy contracts:
   Create a deployment script (e.g., scripts/deploy.js):
   const hre = require("hardhat");

   async function main() {
     const [deployer] = await hre.ethers.getSigners();

     // Deploy Token
     const Token = await hre.ethers.getContractFactory("Token");
     const token = await Token.deploy("Test Token", "TTK", hre.ethers.parseEther("1000000"));
     await token.waitForDeployment();

     // Deploy Factory
     const Factory = await hre.ethers.getContractFactory("Factory");
     const factory = await Factory.deploy();
     await factory.waitForDeployment();

     // Deploy Router
     const Router = await hre.ethers.getContractFactory("Router");
     const router = await Router.deploy(factory.target);
     await router.waitForDeployment();

     // Deploy Staking Token (LP Token)
     const StakingToken = await hre.ethers.getContractFactory("Token");
     const stakingToken = await StakingToken.deploy("LP Token", "LPT", hre.ethers.parseEther("1000000"));
     await stakingToken.waitForDeployment();

     // Deploy Reward Token
     const RewardToken = await hre.ethers.getContractFactory("Token");
     const rewardToken = await RewardToken.deploy("Reward Token", "RWD", hre.ethers.parseEther("100000"));
     await rewardToken.waitForDeployment();

     // Deploy Staking
     const Staking = await hre.ethers.getContractFactory("Staking");
     const staking = await Staking.deploy(
       stakingToken.target,
       rewardToken.target,
       Math.floor(Date.now() / 1000) + 60, // Start in 1 minute
       Math.floor(Date.now() / 1000) + 604800, // End in 1 week
       hre.ethers.parseEther("50000") // Total rewards
     );
     await staking.waitForDeployment();

     console.log("Token deployed to:", token.target);
     console.log("Factory deployed to:", factory.target);
     console.log("Router deployed to:", router.target);
     console.log("Staking Token deployed to:", stakingToken.target);
     console.log("Reward Token deployed to:", rewardToken.target);
     console.log("Staking deployed to:", staking.target);
   }

   main().catch((error) => {
     console.error(error);
     process.exitCode = 1;
   });
   Run the deployment:
   npx hardhat run scripts/deploy.js --network sepolia

## Usage

1. Add Liquidity:
   - Approve the Router to spend your tokens.
   - Call addLiquidity on the Router contract with token addresses and amounts.

2. Swap Tokens:
   - Approve the Router to spend your input token.
   - Call swapExactTokensForTokens or swapTokensForExactTokens with the desired path.

3. Stake LP Tokens:
   - Approve the Staking contract to spend your LP tokens.
   - Call stake with the amount to stake.

4. Withdraw Rewards:
   - Call getReward on the Staking contract to claim rewards.
   - Call withdraw to unstake LP tokens.

## Contract Interaction Diagram

![image](https://github.com/user-attachments/assets/e3e6a508-35b7-4e16-acfc-ef7dd139fc77)


- Token: Base ERC-20 token for trading and rewards.
- Factory: Creates Pair contracts for liquidity pools.
- Pair: Manages liquidity and swaps for a token pair.
- Router: Simplifies interactions with Pair contracts.
- Staking: Manages staking of LP tokens and reward distribution.

## Potential Improvements
- Add tests using Hardhat or Mocha/Chai.
- Implement a frontend interface with React and ethers.js.
- Include fee mechanisms for swaps (e.g., 0.3% fee).
- Enhance security with reentrancy guards and formal audits.

## License
This project is licensed under the MIT License.

---

Feel free to contribute or reach out with questions!
