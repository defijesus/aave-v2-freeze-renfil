// SPDX-License-Identifier: MIT

/*
   _      ΞΞΞΞ      _
  /_;-.__ / _\  _.-;_\
     `-._`'`_/'`.-'
         `\   /`
          |  /
         /-.(
         \_._\
          \ \`;
           > |/
          / //
          |//
          \(\
           ``
     defijesus.eth
*/

pragma solidity 0.8.11;

interface IProposalGenericExecutor {
    function execute() external;
}

interface ILendingPoolConfigurator {
    function freezeReserve(
        address asset
    ) external;

    function setReserveFactor(
        address asset,
        uint256 reserveFactor
    ) external;
}
// TODO Snapshot link
// This payload freezes the renFIL aave v2 market and sets the reserve factor to 100%
// in preparation for Ren 1.0 Network wind down.
// https://governance.aave.com/t/arc-freeze-renfil-for-aave-v2-eth-market/10727
// https://snapshot.org/#/aave.eth/proposal/0x19df23070be999efbb7caf6cd35c320eb74dd119bcb15d003dc2e82c2bbd0d94
contract RenFilRiskParamsUpdate is IProposalGenericExecutor {
    address public constant RENFIL = 0xD5147bc8e386d91Cc5DBE72099DAC6C9b99276F5;
    address public constant LENDING_POOL_CONFIGURATOR = 0x311Bb771e4F8952E6Da169b425E7e92d6Ac45756;

    function execute() external override {
        ILendingPoolConfigurator(LENDING_POOL_CONFIGURATOR).freezeReserve(RENFIL);
        // TODO is this also necessary?
        ILendingPoolConfigurator(LENDING_POOL_CONFIGURATOR).setReserveFactor(RENFIL, 10_000);
    }
}
