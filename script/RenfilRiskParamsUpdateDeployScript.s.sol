// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.11;

import "forge-std/Script.sol";
import "src/RenFilRiskParamsUpdate.sol";


contract RenfilRiskParamsUpdateDeployScript is Script {

    function run() external {
        vm.startBroadcast();

        RenFilRiskParamsUpdate payload = new RenFilRiskParamsUpdate();

        vm.stopBroadcast();
    }
}