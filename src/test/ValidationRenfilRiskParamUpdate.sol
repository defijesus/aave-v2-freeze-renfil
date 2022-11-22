// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import {AaveV2Helpers, ReserveConfig} from "./utils/AaveV2Helpers.sol";
import {AaveGovHelpers, IAaveGov} from "./utils/AaveGovHelpers.sol";

import {RenFilRiskParamsUpdate} from "../RenFilRiskParamsUpdate.sol";

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transfer(address to, uint256 amount) external;
}

interface ILendingPool {
    /**
     * @dev Withdraws an `amount` of underlying asset from the reserve, burning the equivalent aTokens owned
     * E.g. User has 100 aUSDC, calls withdraw() and receives 100 USDC, burning the 100 aUSDC
     * @param asset The address of the underlying asset to withdraw
     * @param amount The underlying amount to be withdrawn
     *   - Send the value type(uint256).max in order to withdraw the whole aToken balance
     * @param to Address that will receive the underlying, same as msg.sender if the user
     *   wants to receive it on his own wallet, or a different address if the beneficiary is a
     *   different wallet
     * @return The final amount withdrawn
     **/
    function withdraw(
        address asset,
        uint256 amount,
        address to
    ) external returns (uint256);

    /**
     * @dev Deposits an `amount` of underlying asset into the reserve, receiving in return overlying aTokens.
     * - E.g. User deposits 100 USDC and gets in return 100 aUSDC
     * @param asset The address of the underlying asset to deposit
     * @param amount The amount to be deposited
     * @param onBehalfOf The address that will receive the aTokens, same as msg.sender if the user
     *   wants to receive them on his own wallet, or a different address if the beneficiary of aTokens
     *   is a different wallet
     * @param referralCode Code used to register the integrator originating the operation, for potential rewards.
     *   0 if the action is executed directly by the user, without any middle-man
     **/
    function deposit(
        address asset,
        uint256 amount,
        address onBehalfOf,
        uint16 referralCode
    ) external;
}

contract ValidationRenfilRiskParamUpdate is Test {
    address internal constant AAVE_WHALE =
        0x25F2226B597E8F9514B3F68F00f494cF4f286491;

    address internal constant RENFIL = 0xD5147bc8e386d91Cc5DBE72099DAC6C9b99276F5;

    address public constant A_RENFIL = 0x514cd6756CCBe28772d4Cb81bC3156BA9d1744aa;

    address public constant A_RENFIL_WHALE = 0x0fCCef1C29dEDdB1E2A007Ee9C1EDf63149aA6b3;

    ILendingPool public constant AAVE_LENDING_POOL = ILendingPool(0x7d2768dE32b0b80b7a3454c06BdAc94A69DDc7A9);

    // can't be constant for some reason
    string internal MARKET_NAME = "AaveV2Ethereum";

    function setUp() public {}

    /// @dev Uses an already deployed payload on the target network
    function testProposalPostPayload() public {
        /// deploy payload
        RenFilRiskParamsUpdate payload = new RenFilRiskParamsUpdate();
        _testProposal(address(payload));
    }

    function _testProposal(address payload) internal {
        ReserveConfig[] memory allConfigsBefore = AaveV2Helpers
            ._getReservesConfigs(false, MARKET_NAME);

        address[] memory targets = new address[](1);
        targets[0] = payload;
        uint256[] memory values = new uint256[](1);
        values[0] = 0;
        string[] memory signatures = new string[](1);
        signatures[0] = "execute()";
        bytes[] memory calldatas = new bytes[](1);
        calldatas[0] = "";
        bool[] memory withDelegatecalls = new bool[](1);
        withDelegatecalls[0] = true;

        uint256 proposalId = AaveGovHelpers._createProposal(
            vm,
            AAVE_WHALE,
            IAaveGov.SPropCreateParams({
                executor: AaveGovHelpers.SHORT_EXECUTOR,
                targets: targets,
                values: values,
                signatures: signatures,
                calldatas: calldatas,
                withDelegatecalls: withDelegatecalls,
                ipfsHash: bytes32(0)
            })
        );

        AaveGovHelpers._passVote(vm, AAVE_WHALE, proposalId);

        ReserveConfig[] memory allConfigsAfter = AaveV2Helpers
            ._getReservesConfigs(false, MARKET_NAME);

        ReserveConfig memory reserveConfigBefore = AaveV2Helpers._findReserveConfig(allConfigsBefore, "renFIL", true);
        ReserveConfig memory reserveConfigAfter = AaveV2Helpers._findReserveConfig(allConfigsAfter, "renFIL", true);

        assertEq(reserveConfigBefore.isFrozen, false);
        assertEq(reserveConfigAfter.isFrozen, true);
        assertEq(reserveConfigAfter.reserveFactor, 10_000);

        // checking if it's still possible to withdraw from the market
        vm.startPrank(A_RENFIL_WHALE);
        uint256 aBalance = IERC20(A_RENFIL).balanceOf(A_RENFIL_WHALE);
        uint256 balanceBefore = IERC20(RENFIL).balanceOf(A_RENFIL_WHALE);
        AAVE_LENDING_POOL.withdraw(RENFIL, aBalance , A_RENFIL_WHALE);
        uint256 balanceAfter = IERC20(RENFIL).balanceOf(A_RENFIL_WHALE);
        vm.stopPrank();
        assertEq(balanceAfter == balanceBefore + aBalance , true);
    }
}
