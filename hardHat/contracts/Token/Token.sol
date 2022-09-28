// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./interface/ERC20.sol";
import "../utils/Ownable.sol";

contract Token is ERC20, Ownable {
    constructor() ERC20("Token", "Tk") {}

    function mint(address _account, uint256 _amount) external onlyOwner {
        _mint(_account, _amount);
    }

    function burn(uint256 _amount) external {
        _burn(msg.sender, _amount);
    }
}
