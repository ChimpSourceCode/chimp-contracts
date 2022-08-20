// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ChimpDAO is ERC20, Ownable {
    uint256 public constant MAX_SUPPLY = 2800000000 * 1e18; // 2.8 billions

    constructor() ERC20("ChimpDAO", "CHIMP") {
        mint(msg.sender,MAX_SUPPLY);
    }

    function mint(address user, uint256 amount) public onlyOwner {
        require(totalSupply() + amount <= MAX_SUPPLY, "Max Supply Exceeds");
        _mint(user, amount);
    }
}
