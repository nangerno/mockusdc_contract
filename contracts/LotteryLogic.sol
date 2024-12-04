// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";

contract LotteryLogic is VRFConsumerBaseV2 {
    IERC20 public mockUSDC;
    IERC20Burnable public burnableUSDC; // Interface for burnable tokens
    VRFCoordinatorV2Interface COORDINATOR;

    address public creator;
    uint public entryFee;
    uint public endTime;
    address[] public participants;
    bool public hasEnded;
    address public winner;

    uint64 private subscriptionId;
    bytes32 private keyHash;
    uint32 private callbackGasLimit = 100000;
    uint16 private requestConfirmations = 3;

    mapping(uint256 => uint) private requestIdToIndex;

    event LotteryJoined(address participant);
    event RandomnessRequested(uint256 requestId);
    event WinnerDeclared(address winner);
    event TokensBurned(uint amount);

    constructor(
        address _creator,
        uint _entryFee,
        uint _duration,
        address _mockUSDC,
        address _vrfCoordinator,
        uint64 _subscriptionId,
        bytes32 _keyHash
    ) VRFConsumerBaseV2(_vrfCoordinator) {
        creator = _creator;
        entryFee = _entryFee;
        endTime = block.timestamp + _duration;
        mockUSDC = IERC20(_mockUSDC);
        burnableUSDC = IERC20Burnable(_mockUSDC); // Cast token as burnable
        COORDINATOR = VRFCoordinatorV2Interface(_vrfCoordinator);
        subscriptionId = _subscriptionId;
        keyHash = _keyHash;
    }

    function joinLottery() external {
        require(block.timestamp < endTime, "Lottery has ended");
        require(!hasEnded, "Lottery already ended");

        mockUSDC.transferFrom(msg.sender, address(this), entryFee);
        participants.push(msg.sender);

        emit LotteryJoined(msg.sender);
    }

    function pickWinner() external {
        require(block.timestamp >= endTime, "Lottery is still ongoing");
        require(!hasEnded, "Winner already declared");
        require(participants.length > 0, "No participants in the lottery");

        uint256 requestId = COORDINATOR.requestRandomWords(
            keyHash,
            subscriptionId,
            requestConfirmations,
            callbackGasLimit,
            1
        );

        requestIdToIndex[requestId] = participants.length; // Track this lottery
        emit RandomnessRequested(requestId);
    }

    function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords) internal override {
        require(participants.length > 0, "No participants available");

        uint randomIndex = randomWords[0] % participants.length;
        winner = participants[randomIndex];
        hasEnded = true;

        emit WinnerDeclared(winner);
    }

    function withdrawPrize() external {
        require(msg.sender == winner, "You are not the winner");
        require(hasEnded, "Lottery is still active");

        uint prizePool = entryFee * participants.length;

        uint burnAmount = (prizePool * 10) / 100; // 10% of prize pool to burn
        uint payout = prizePool - burnAmount;

        // Burn 10% of the prize pool
        burnableUSDC.burn(burnAmount);
        emit TokensBurned(burnAmount);

        // Transfer remaining prize to the winner
        mockUSDC.transfer(winner, payout);

        winner = address(0); // Prevent re-entrancy
    }
}
