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
