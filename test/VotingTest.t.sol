// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import {TPUToken} from "../src/TPUToken.sol";
import {VotingEngine,InvalidAllowance, NotAnOwner,TooMuchOptions,NotStarted,Ended,AlreadyVoted,StillOpen } from "../src/VotingEngine.sol";

contract VotingEngineTest is Test {
    TPUToken tpu;
    VotingEngine voting;
    address voteAddr;
    address owner;
    address sasha = makeAddr("sasha");
    uint startAt;
    function setUp() public{
        owner = address(this);
        tpu = new TPUToken(250);
        tpu.transfer(sasha,withDecimals(10));
        voting = new VotingEngine(address(tpu));
        voteAddr = address(voting);
        startAt = block.timestamp;
    }
    function withDecimals(uint _amount) private view returns(uint){
        return _amount *10 **tpu.decimals();
    }
    function testCreateVotingAndVote() external {
        uint amount = withDecimals(10);
        uint amountX2 = withDecimals(20);
        voting.createVoting(10,"test",["zero","one","two","three","four"]);
        tpu.approve(voteAddr,amountX2);
        assertEq(tpu.allowance(owner,voteAddr),amountX2);
        voting.vote(0,0,amountX2);
        vm.prank(sasha);
        tpu.approve(voteAddr,amount);
        assertEq(tpu.allowance(sasha,voteAddr),amount);
        vm.prank(sasha);
        voting.vote(0,1,amount);


        vm.warp(startAt + 10 seconds);
        assertEq(voting.getResults(0),"zero");
    }
    function testCantGetResultsIfNotEnded() external {
        uint amount = withDecimals(10);
        voting.createVoting(10,"test",["zero","one","two","three","four"]);
        tpu.approve(voteAddr,amount*2);
        voting.vote(0,0,amount);
        vm.warp(startAt +7 seconds);
        vm.expectRevert(StillOpen.selector);
        voting.getResults(0);
    }
    function testVoteTwice() external {
        uint amount = withDecimals(10);
        uint amountX2 = withDecimals(20);
        voting.createVoting(10,"test",["zero","one","two","three","four"]);
        tpu.approve(voteAddr,amountX2);
        voting.vote(0,0,amount);
        vm.expectRevert(AlreadyVoted.selector);
        voting.vote(0,0,amount);
    }
    function testVoteOnNonExistingVoting() external {
        uint amount = withDecimals(10);
        voting.createVoting(10,"test",["zero","one","two","three","four"]);
        tpu.approve(voteAddr,amount*2);
        voting.vote(0,0,amount);
        vm.expectRevert(NotStarted.selector);
        voting.vote(1,0,amount);
    }
    function testWithdraw() external {
        uint amount = withDecimals(10);
        voting.createVoting(10,"test",["zero","one","two","three","four"]);
        tpu.approve(voteAddr,amount);
        voting.vote(0,0,amount);
        uint initialBalance = tpu.balanceOf(owner);
        voting.withdrawTokens();
        assertEq(tpu.balanceOf(owner),initialBalance + amount);
    }
    // function staticToDynamicArr(string[5] memory arr) private pure returns(string[] memory){
    //     string[] memory dynArr;
    //     for (uint i = 0; i < arr.length; i++) {
    //         dynArr[i] = arr[i];
    //     }
    //     return dynArr;
    // }

}