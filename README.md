# ERC20 101

## Introduction

Welcome! This is an automated workshop that will explain how to deploy and ERC20 token, and customize it to perform specific functions.
It is aimed at developpers that have never written code in Solidity, but who understand its syntax.

## How to work on this TD

### Introduction

The TD has two components:

- An ERC20 token, ticker TD-ERC20-101, that is used to keep track of points
- An evaluator contract, that is able to mint and distribute TD-ERC20-101 points

Your objective is to gather as many TD-ERC20-101 points as possible. Please note :

- The 'transfer' function of TD-ERC20-101 has been disabled to encourage you to finish the TD with only one address
- You can answer the various questions of this workshop with different ERC20 contracts. However, an evaluated address has only one evaluated ERC20 contract at a time. To change the evaluated ERC20 contract associated with your address, call `submitExercice()` with that specific address.
- In order to receive points, you will have to do execute code in `Evaluator.sol` such that the function `TDERC20.distributeTokens(msg.sender, n);` is triggered, and distributes n points.
- This repo contains an interface `IExerciceSolution.sol`. Your ERC20 contract will have to conform to this interface in order to validate the exercice; your contract needs to implement all the functions described in `IExerciceSolution.sol`.
- A high level description of what is expected for each exercice is in this readme. A low level description of what is expected can be inferred by reading the code in `Evaluator.sol`.
- The Evaluator contract sometimes needs to make payments to buy your tokens. Make sure he has enough TBNB to do so! If not, you can TBNB ETH directly to the contract.

## Points list

### Setting up

- Fork this repository.
- Create an env file with `cp .env.copy .env` and fill in the variables _*BSC_TESTNET_RPC_URL*_ and _*PRIVATE_KEY*_.

### ERC20 basics

- Create an ERC20 token contract which inherits `IExerciseSolution.sol`.
- Call `submitExercice()` in the Evaluator to configure the contract you want evaluated (5 points).
- Call `ex1_getTickerAndSupply()` in the evaluator contract to receive a random ticker for your ERC20 token, as well as an initial token supply (1 pt). You can read your assigned ticker and supply in `Evaluator.sol` by calling getters `readTicker()` and `readSupply()`
- Call `ex2_testErc20TickerAndSupply()` in the evaluator to receive your points (2 pts)

### Distributing and selling tokens

- Create a `getToken()` function in your contract, deploy it, and call the `ex3_testGetToken()` function that distributes token to the caller (2 pts).
- Create a `buyToken()` function in your contract, deploy it, and call the `ex4_testBuyToken()` function that lets the caller send an arbitrary amount of ETH, and distributes a proportionate amount of token (2 pts).

### Creating an ICO allow list

- Create a customer allow listing function. Only allow listed users should be able to call `getToken()`
- Call `ex5_testDenyListing()` in the evaluator to show he can't buy tokens using `buyTokens()` (1 pt)
- Allow the evaluator to buy tokens
- Call `ex6_testAllowListing()`in the evaluator to show he can now buy tokens `buyTokens()` (2 pt)

### Creating multi tier allow list

- Create a customer multi tier listing function. Only allow listed users should be able to call `buyToken()`; and customers should receive a different amount of token based on their level
- Call `ex7_testDenyListing()` in the evaluator to show he can't buy tokens using `buyTokens()` (1 pt)
- Add the evaluator in the first tier. He should now be able to buy N tokens for Y amount of ETH
- Call `ex8_testTier1Listing()` in the evaluator to show he can now buy tokens(2 pt)
- Add the evaluator in the second tier. He should now be able to buy 2N tokens for Y amount of ETH
- Call `ex9_testTier2Listing()` in the evaluator to show he can now buy more tokens(2 pt)

### All in one

- Finish all the workshop in a single transaction! Write a contract that implements a function called `completeWorkshop()` when called. Call `ex10_allInOne()` from this contract. All points are credited to the validating contract (2pt)

### Extra points

Extra points if you find bugs / corrections in this TD.

## TD addresses

- network : [BNB Smart chain Testnet](https://chainlist.org/chain/97)

- ERC20TD [`0xe68CBd77b917F18Fa91A2d07eEE67b9551fD8eb4`](https://testnet.bscscan.com/address/0xe68CBd77b917F18Fa91A2d07eEE67b9551fD8eb4)
- Evaluator [`0x319C4Cc9Cca7359B95858885c4fBf99A1d6A2E8a`](https://testnet.bscscan.com/address/0x319C4Cc9Cca7359B95858885c4fBf99A1d6A2E8a)
