// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

enum Status {
    Pending,
    Phase1Failed,
    Phase1Passed,
    Available,
    Unavailable,
    Inconclusive
}

struct Post {
    bytes32 postId;
    bytes32 cidHash;
    bytes32 kzgCommit;
    Status status;
}
