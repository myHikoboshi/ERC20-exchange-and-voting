//SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import {TPUToken} from "../src/TPUToken.sol";
import {TokenExchange,InsufficientTokens,InvalidAllowance} from "../src/TokenExchange.sol";

contract TokenExchangeTest is Test{
    TPUToken tpu;
    TokenExchange exchange;
    address exchAddr;
    address owner;
    uint256 exchTokenBalance = 50;
    address sasha = makeAddr("sasha");
    address egor = makeAddr("egor");
    function setUp() public{
        owner = address(this);
        tpu = new TPUToken(250);
        exchange = new TokenExchange(address(tpu));
        exchAddr = address(exchange);
        tpu.transfer(exchAddr,withDecimals(exchTokenBalance));
        exchange.topUp{value: 10 ether}();
    }
    function withDecimals(uint _amount) private view returns(uint){
        return _amount *10 **tpu.decimals();
    }
    function testBuy() external {
        uint amount = 3 ether;
        uint initialBalance = exchAddr.balance;
        hoax(sasha);
        exchange.buy{value: amount}();
        assertEq(exchAddr.balance,initialBalance + amount);
        assertEq(tpu.balanceOf(exchAddr),withDecimals(exchTokenBalance)-amount);
        assertEq(tpu.balanceOf(sasha),amount);
    }
    function testRevertBuyWhenNoTokens() external{
        uint amount = 1000 ether;
        vm.expectRevert(
            abi.encodeWithSelector(InsufficientTokens.selector, amount,tpu.balanceOf(exchAddr))
        );
        exchange.buy{value:amount}();
    }
    function testSell() external {
        uint amount = withDecimals(10);
        uint ownerInitialBalance = owner.balance;
        uint ownerTokenBalance = tpu.balanceOf(owner);
        tpu.approve(exchAddr,amount);
        assertEq(tpu.allowance(owner,exchAddr),amount);
        exchange.sell(amount);
        assertEq(owner.balance,ownerInitialBalance+amount);
        assertEq(tpu.balanceOf(owner),ownerTokenBalance - amount);
        assertEq(tpu.allowance(owner,exchAddr),0);
    }
    receive() external payable {
    }



}
