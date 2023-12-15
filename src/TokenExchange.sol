// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {IERC20} from "./IERC20.sol";

error InsufficientTokens(uint256 requested, uint256 available);
error InsufficientFunds(uint256 requested, uint256 available);
error InvalidAllowance(address owner,address spender, uint256 amount);

contract TokenExchange {
    IERC20 token;
    address public owner;

    event Bought(uint _amount, address indexed _buyer);
    event Sold(uint _amount, address indexed _seller);

    constructor(address _token) {
        token = IERC20(_token);
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "not an owner!");
        _;
    }

    function buy() public payable {
        uint amount = msg.value; // 1 wei = 1 token
        require (amount>0,"Invalid amount!");
        if (amount>token.balanceOf(address(this))){
            revert InsufficientTokens(amount,token.balanceOf(address(this)));
        }
        token.transfer(msg.sender,amount);
    }

    function sell(uint _amount) external {
        if (address(this).balance<_amount){
            revert InsufficientFunds(_amount, address(this).balance);
        }
        require(
            _amount > 0 &&
            token.balanceOf(msg.sender) >= _amount,
            "incorrect amount!"
        );
        if (token.allowance(msg.sender, address(this))<_amount){
            revert InvalidAllowance(msg.sender,address(this),_amount);
        }

        token.transferFrom(msg.sender, address(this), _amount);

        (bool success,) = msg.sender.call{value: _amount}("");
        require(success,"Transfer failed!");
        emit Sold(_amount, msg.sender);
    }

    receive() external payable {
        buy();
    }
    function topUp() external payable onlyOwner{

    }
}