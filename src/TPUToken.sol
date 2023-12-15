// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {ERC20} from "./ERC20.sol";
import {ERC20Burnable} from "./ERC20Burnable.sol";

contract TPUToken is ERC20, ERC20Burnable{
    address public owner;
    modifier onlyOwner(){
        require (msg.sender == owner,"not an owner!");
        _;
    }

    constructor(uint premintAmount) ERC20("TPUToken", "TPU") {
        owner = msg.sender;
        _mint(owner,premintAmount * 10 ** decimals());
    }

    function mint(address to, uint amount) public onlyOwner{
        _mint(to,amount);
    }

}