// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../contracts/MockKzgVerifier.sol";
import "./TestBase.sol";

contract MockKzgVerifierTest is TestBase {
    MockKzgVerifier private verifier;

    function setUp() external {
        verifier = new MockKzgVerifier();
    }

    function testVerifyFlagCanBeToggled() external {
        assertTrue(verifier.verifyKzgOpening("", "", ""), "should verify by default");
        verifier.setShouldVerify(false);
        assertTrue(!verifier.verifyKzgOpening("", "", ""), "should flip");
    }
}
