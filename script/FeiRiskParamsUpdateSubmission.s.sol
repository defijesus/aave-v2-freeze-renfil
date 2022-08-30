// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.11;

import "forge-std/Test.sol";
import "forge-std/Script.sol";

import {AaveGovHelpers, IAaveGov} from "src/test/utils/AaveGovHelpers.sol";

contract FeiRiskParamsUpdateSubmitScript is Script, Test {

    address internal constant PAYLOAD = 0xB8FE2A2104AFB975240d3D32A7823A01Cb74639F;

    bytes32 internal constant IPFS_HASH = bytes32(0x86fb2c1c7056f55ddfebe82b634419b2170c5cb5b981df6a0d19523dba959575);

    IAaveGov internal constant GOV =
        IAaveGov(0xEC568fffba86c094cf06b22134B23074DFE2252c);

    function run() external {
        vm.startBroadcast();

        address[] memory targets = new address[](1);
        targets[0] = PAYLOAD;
        uint256[] memory values = new uint256[](1);
        values[0] = 0;
        string[] memory signatures = new string[](1);
        signatures[0] = "execute()";
        bytes[] memory calldatas = new bytes[](1);
        calldatas[0] = "";
        bool[] memory withDelegatecalls = new bool[](1);
        withDelegatecalls[0] = true;

        uint256 proposalId = GOV.create(
            AaveGovHelpers.SHORT_EXECUTOR,
            targets,
            values,
            signatures,
            calldatas,
            withDelegatecalls,
            IPFS_HASH
        );

        vm.stopBroadcast();
    }
}