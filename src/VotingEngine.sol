// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import {TPUToken} from "../src/TPUToken.sol";

error InvalidAllowance(address owner,address spender, uint256 amount);
error NotAnOwner();
error TooMuchOptions();
error NotStarted();
error Ended();
error AlreadyVoted();
error StillOpen();

contract VotingEngine {

    address public owner;
    uint constant optionNumber = 5;
    TPUToken public tpu;
    
    struct Voting {
        string title;
        uint startsAt;
        uint endsAt;
        option[] options;
        bool votingStarted;
        mapping(address=> bool) votingParticipants;
    }

    struct option{
        uint id;
        string title;
        uint tokenCount;
    }

    uint votingIndex = 0;
    mapping(uint=>Voting) votings;

   

    modifier onlyOwner() {
        if (msg.sender!=owner){
            revert NotAnOwner();
        }
        _;
    }

    constructor(address _tpu){
        owner = msg.sender;
        tpu = TPUToken(_tpu);
    }

    function createVoting(uint _duration, string memory _title, string[optionNumber] memory _optionTitles) external {
        require(_duration>0,"Invalid duration!");
        
        Voting storage newVoting = votings[votingIndex];
        newVoting.title = _title;
        newVoting.startsAt = block.timestamp;
        newVoting.endsAt = block.timestamp + _duration;
        
        for (uint i = 0; i < _optionTitles.length; i++) {
            newVoting.options.push(option({
                id: i,
                title: _optionTitles[i],
                tokenCount: 0
            }));
        }
        
        newVoting.votingStarted = true;
        votingIndex++;

    }

    function vote(uint _votingIndex, uint _optionIndex, uint _amount) external{

        require(_amount>0,"Vote only for tokens!");

        Voting storage voting = votings[_votingIndex];

        if (!voting.votingStarted){
            revert NotStarted();
        }
        if (block.timestamp>=voting.endsAt){
            revert Ended();
        }
        if (voting.votingParticipants[msg.sender]){
            revert AlreadyVoted();
        }
        
        if (tpu.allowance(msg.sender, address(this))<_amount){
            revert InvalidAllowance(msg.sender,address(this),_amount);
        }

        tpu.transferFrom(msg.sender, address(this), _amount);

        voting.options[_optionIndex].tokenCount+=_amount;
        voting.votingParticipants[msg.sender] = true;
    }

    function getResults(uint _votingIndex) external view returns (string memory) {
        
        Voting storage voting = votings[_votingIndex];
        if (block.timestamp <votings[_votingIndex].endsAt){
            revert StillOpen();
        }
        uint maxNum;
        string memory winnerTitle;
        for (uint i = 0; i < voting.options.length; i++) {
            if (voting.options[i].tokenCount > maxNum){
                maxNum = voting.options[i].tokenCount;
                winnerTitle = voting.options[i].title;
            }
        }
        return winnerTitle;
    }

    function withdrawTokens() external onlyOwner {
        tpu.transfer(msg.sender,tpu.balanceOf(address(this)));
    }
}
