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
   git clone https://github.com/your-username/your-repo-name.git
   cd your-repo-name
