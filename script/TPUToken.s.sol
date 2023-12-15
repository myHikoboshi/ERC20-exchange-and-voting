// SPDX-License-Identifier: MIT
//forge script script/TPUToken.s.sol:TPUDeploy --fork-url http://localhost:8545 --broadcast
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/TPUToken.sol";

contract TPUDeploy is Script{
    function run() external{
        address to = 0x70997970C51812dc3A010C7d01b50e0d17dc79C8;
        uint amount = 5;
        uint deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);
        TPUToken token = new TPUToken(100);
        token.transfer(to, amount * 10 ** token.decimals());
        vm.stopBroadcast();
    }
}