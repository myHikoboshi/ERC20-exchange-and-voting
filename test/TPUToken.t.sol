// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import {TPUToken} from "../src/TPUToken.sol";

contract TPUTokenTest is Test {
    TPUToken token;
    address sasha = makeAddr("sasha");
    address egor = makeAddr("egor");

    function setUp() public {
        token = new TPUToken(123);
    }

    function testInitialSupply() external{
        assertEq(token.totalSupply(),123*10**token.decimals());
    }

    function testTransfer() external {
        token.transfer(sasha,10);
        assertEq(token.balanceOf(sasha),10);
    }

    function testTranserFrom() external{
        uint totalAmount = 10;
        uint transferAmount = 8;

        token.approve(egor,totalAmount);

        vm.prank(egor);
        token.transferFrom(address(this),sasha,transferAmount);
        assertEq(token.allowance(address(this),egor),totalAmount - transferAmount);
        assertEq(token.balanceOf(sasha),transferAmount);
    }

    function testMint() external{
        uint initialSupply = token.totalSupply();
        token.mint(sasha,10);
        assertEq(token.totalSupply(),initialSupply+10);
        assertEq(token.balanceOf(sasha),10);

    }

    function testBurn() external {
        uint initialSupply = token.totalSupply();
        token.transfer(sasha,10);
        vm.prank(sasha);
        token.burn(10);
        assertEq(token.totalSupply(),initialSupply-10);
        assertEq(token.balanceOf(sasha),10-10);
    }




}