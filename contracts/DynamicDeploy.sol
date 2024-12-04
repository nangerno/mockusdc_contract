// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./LotteryLogic.sol";

contract LotteryFactory {
    address[] public deployedLotteries;

    event LotteryCreated(address lotteryAddress, address creator);

    function createLottery(
        uint _entryFee,
        uint _duration,
        address _mockUSDC,
        address _vrfCoordinator,
        uint64 _subscriptionId,
        bytes32 _keyHash
    ) external {
        // Dynamically deploy a new lottery contract
        LotteryLogic newLottery = new LotteryLogic(
            msg.sender,
            _entryFee,
            _duration,
            _mockUSDC,
            _vrfCoordinator,
            _subscriptionId,
            _keyHash
        );

        deployedLotteries.push(address(newLottery));

        emit LotteryCreated(address(newLottery), msg.sender);
    }

    function getDeployedLotteries() external view returns (address[] memory) {
        return deployedLotteries;
    }
}
