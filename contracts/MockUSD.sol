// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MockUSDC is ERC20, Ownable {
    event BalanceChecked(address account, uint256 balance);
    event TokensMinted(address to, uint256 amount);
    event TokensBurned(address from, uint256 amount);

    constructor(uint256 initialSupply) ERC20("UYJCoin", "USDC") Ownable(msg.sender) {
        _mint(msg.sender, initialSupply);
    }
    function balanceOf(address account) public view override returns (uint256) {
        return super.balanceOf(account);
    }
    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
        emit TokensMinted(to, amount);
    }
    function burn(uint256 amount) public {
        _burn(msg.sender, amount);
        emit TokensBurned(msg.sender, amount);
    }
}