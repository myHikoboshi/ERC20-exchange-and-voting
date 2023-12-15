// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/extensions/ERC20Burnable.sol)

pragma solidity ^0.8.20;

import {ERC20} from "./ERC20.sol";
abstract contract ERC20Burnable is ERC20 {

    function burn(uint256 value) public virtual {
        _burn(msg.sender, value);
    }
    function burnFrom(address account, uint256 value) public virtual {
        _spendAllowance(account, msg.sender, value);
        _burn(account, value);
    }
}