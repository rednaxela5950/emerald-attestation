// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface Vm {
    function expectRevert(bytes calldata) external;
}

abstract contract TestBase {
    Vm internal constant vm = Vm(address(uint160(uint256(keccak256("hevm cheat code")))));

    function assertEq(bytes32 a, bytes32 b, string memory message) internal pure {
        if (a != b) revert(message);
    }

    function assertEq(uint256 a, uint256 b, string memory message) internal pure {
        if (a != b) revert(message);
    }

    function assertTrue(bool condition, string memory message) internal pure {
        if (!condition) revert(message);
    }
}
