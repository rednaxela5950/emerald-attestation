// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./EmeraldPostRegistry.sol";
import "./EmeraldTypes.sol";

contract EmeraldDaAdapter {
    struct Phase1State { uint256 yesStake; uint256 totalStake; address[] yesVoters; }
    struct CustodyChallenge { address operator; uint256 challengeIndex; bool responded; bool success; }

    event Phase1DaPassed(bytes32 indexed postId, uint256 yesStake, uint256 totalStake);
    event Phase1DaFailed(bytes32 indexed postId, uint256 yesStake, uint256 totalStake);
    event CustodyChallengeStarted(bytes32 indexed postId, address indexed operator, uint256 challengeIndex);
    event CustodyProofSubmitted(bytes32 indexed postId, address indexed operator, bool success);
    event PostFinalized(bytes32 indexed postId, Status finalStatus);

    EmeraldPostRegistry public registry;
    mapping(bytes32 => Phase1State) private phase1States;
    mapping(bytes32 => CustodyChallenge[]) private custodyChallenges;

    constructor(EmeraldPostRegistry registry_) { registry = registry_; }

    function setRegistry(EmeraldPostRegistry registry_) external {
        require(address(registry) == address(0), "REGISTRY_SET");
        registry = registry_;
    }

    function handlePhase1Result(bytes32 postId, bytes32 cidHash, bytes32 kzgCommit, address[] calldata yesVoters, uint256 yesStake, uint256 totalStake, bool passed) external {
        require(address(registry) != address(0), "REGISTRY_MISSING");
        Post memory post = registry.getPost(postId);
        require(post.postId != bytes32(0), "POST_MISSING");
        require(post.cidHash == cidHash && post.kzgCommit == kzgCommit, "POST_MISMATCH");
        phase1States[postId] = Phase1State(yesStake, totalStake, yesVoters);
        registry.setStatusFromDa(postId, passed ? Status.Phase1Passed : Status.Phase1Failed);
        if (passed) emit Phase1DaPassed(postId, yesStake, totalStake);
        else emit Phase1DaFailed(postId, yesStake, totalStake);
    }

    function getPhase1State(bytes32 postId) external view returns (Phase1State memory) {
        return phase1States[postId];
    }

    function getCustodyChallenges(bytes32 postId) external view returns (CustodyChallenge[] memory) {
        return custodyChallenges[postId];
    }
}
