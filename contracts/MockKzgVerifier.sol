// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract MockKzgVerifier {
    bool public shouldVerify = true;

    function setShouldVerify(bool value) external {
        shouldVerify = value;
    }

    function verifyKzgOpening(bytes calldata, bytes calldata, bytes calldata) external view returns (bool) {
        return shouldVerify;
    }
}
