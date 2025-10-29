🪙 BlOClatCh: The On-Chain Pairing Game

💡 Project Description

BlOClatCh is a simple, educational Solidity smart contract designed to explore one of the most fundamental challenges in blockchain development: generating verifiable randomness for games.

It simulates a basic "flip and match" game where players try to match two hidden "cards" (numbers) drawn by the contract. While it's a fun, lightweight concept, it serves as a critical demonstration of why relying on simple on-chain data for randomness is risky!

🕹️ What It Does

This contract acts as a decentralized match-making engine:

A player calls the public play() function.

The contract instantly generates two "cards" (pseudo-random numbers between 1 and 10) using block data and the transaction details.

It checks if card1 equals card2.

If they match, the player scores a point, and the contract updates the totalMatches count.

An event is broadcast to the Ethereum network with the result.

⭐ Key Features

Simple Game Logic: Easy-to-understand state management for total plays and matches.

Events for Transparency: Uses the GamePlayed event to broadcast the result (the two cards and match status) to the world.

Security Focus: Includes a critical warning highlighting the security flaws of using block.timestamp and keccak256 for randomness in production games, guiding beginners toward secure solutions like Chainlink VRF.

Utility Functions: View functions (getTotalPlays, getTotalMatches) for tracking the game's overall performance.

🛠️ Smart Contract Code

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title BlOClatCh - A simple pairing/flipping game concept.
 * @dev This contract demonstrates basic state management, events, and the critical challenge
 * of generating verifiable randomness on-chain for a simple pair-matching game.
 */
contract BlOClatCh {
    // --- State Variables ---
    address public immutable owner;
    uint256 public totalPlays;
    uint256 public totalMatches;

    // --- Events ---
    // Events allow external applications (like a web UI) to efficiently track game results.
    event GamePlayed(
        address indexed player,
        uint256 card1,
        uint256 card2,
        bool matched
    );

    // --- Constructor ---
    // Runs only once when the contract is deployed.
    constructor() {
        owner = msg.sender;
    }

    // --- Core Logic: Pseudo-Random Number Generation ---

    /**
     * @dev Generates a pseudo-random number between 1 and 10.
     * @param seed A unique input to make the result less predictable for this call.
     * @return A number between 1 and 10 (inclusive).
     *
     * !!! CRITICAL SECURITY WARNING !!!
     * This method uses block variables and transaction data, which are publicly known
     * and can be manipulated or predicted by miners/validators.
     * NEVER use this function for games involving significant value (money).
     * For true, verifiable randomness, you must use a decentralized oracle like Chainlink VRF.
     */
    function _generateRandomNumber(uint256 seed) private view returns (uint256) {
        // Combines block data, the player's address, and the play count into a single hash.
        bytes32 hash = keccak256(
            abi.encodePacked(
                block.timestamp,
                msg.sender,
                totalPlays,
                seed
            )
        );

        // Converts the hash to a uint256, then uses modulo to constrain it to 1-10.
        return (uint256(hash) % 10) + 1;
    }

    // --- Main Game Function ---

    /**
     * @notice Allows a player to play one round of BlOClatCh.
     * Two "cards" are generated, and a match is checked.
     */
    function play() public {
        totalPlays++;

        // Generate two "cards" using different seeds to ensure they are likely unique.
        // We simulate the "flip" action here by generating the numbers.
        uint256 card1 = _generateRandomNumber(totalPlays);
        uint256 card2 = _generateRandomNumber(totalPlays + 1);

        bool matched = (card1 == card2);

        if (matched) {
            totalMatches++;
            // In a more complex game, you would add logic here to send the player a reward.
            // For example: (payable) msg.sender.call{value: 1 ether}("");
        }

        // Broadcast the result to the network
        emit GamePlayed(msg.sender, card1, card2, matched);
    }

    // --- Utility/View Functions ---

    /**
     * @notice Returns the total number of games played.
     */
    function getTotalPlays() public view returns (uint256) {
        return totalPlays;
    }

    /**
     * @notice Returns the total number of matches achieved.
     */
    function getTotalMatches() public view returns (uint256) {
        return totalMatches;
    }
}



🔗 Deployed Smart Contract Link:
https://celo-sepolia.blockscout.com/address/0x002D9413EeFc765089Ed2a9E114D3d801d0A735c

You can view the deployed version of the BlOClatCh contract here:

🤝 Getting Started

To test this contract:

Clone this repository.

Compile the code using a tool like Remix or Hardhat.

Deploy it to a testnet (e.g., Sepolia).

Interact with the play() function to see the results and observe the emitted events!