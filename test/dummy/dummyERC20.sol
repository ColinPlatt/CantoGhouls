// SPDX-License-Identifier: The Unlicense
pragma solidity 0.8.15;

import "@Openzeppelin/token/ERC20/ERC20.sol";

contract dummyERC20 is ERC20("dummy", "DUMMY") {
    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }
}
