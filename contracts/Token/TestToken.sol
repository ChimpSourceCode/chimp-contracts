// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract TestToken is ERC20, Ownable {

    constructor() ERC20("Test", "TEST") {
        mint(msg.sender,1000000000000*1e18);
    }

    function mint(address user, uint256 amount) public {
        _mint(user, amount);
    }
}
