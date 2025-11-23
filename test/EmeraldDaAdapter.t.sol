// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../contracts/EmeraldDaAdapter.sol";
import "../contracts/EmeraldPostRegistry.sol";
import "../contracts/EmeraldTypes.sol";
import "../contracts/MockKzgVerifier.sol";
import "./TestBase.sol";

contract EmeraldDaAdapterTest is TestBase {
    EmeraldPostRegistry private registry;
    EmeraldDaAdapter private adapter;
    MockKzgVerifier private verifier;

    function setUp() external {
        verifier = new MockKzgVerifier();
        adapter = new EmeraldDaAdapter(EmeraldPostRegistry(address(0)), address(this), verifier);
        registry = new EmeraldPostRegistry(address(adapter));
        adapter.setRegistry(registry);
    }

    function testHandleDaAttestationUpdatesRegistryAndState() external {
        bytes32 cidHash = keccak256("cid");
        bytes32 kzgCommit = keccak256("kzg");
        bytes32 postId = registry.createPost(cidHash, kzgCommit);
        address[] memory voters = new address[](1);
        voters[0] = address(0x1);
        adapter.handleDaAttestation(postId, cidHash, kzgCommit, voters, 2, 3);
        Post memory post = registry.getPost(postId);
        assertEq(uint256(post.status), uint256(Status.Phase1Passed), "status");
        EmeraldDaAdapter.Phase1State memory state = adapter.getPhase1State(postId);
        assertEq(state.yesStake, 2, "yesStake");
        assertEq(state.totalStake, 3, "totalStake");
        assertEq(state.yesVoters.length, 1, "voters length");
    }

    function testHandleDaAttestationFailsWhenStakeLow() external {
        bytes32 cidHash = keccak256("cid");
        bytes32 kzgCommit = keccak256("kzg");
        bytes32 postId = registry.createPost(cidHash, kzgCommit);
        address[] memory voters = new address[](1);
        voters[0] = address(0x1);
        adapter.handleDaAttestation(postId, cidHash, kzgCommit, voters, 1, 3);
        Post memory post = registry.getPost(postId);
        assertEq(uint256(post.status), uint256(Status.Phase1Failed), "status fail");
    }

    function testHandleDaAttestationRejectsMismatch() external {
        bytes32 cidHash = keccak256("cid");
        bytes32 kzgCommit = keccak256("kzg");
        bytes32 postId = registry.createPost(cidHash, kzgCommit);
        vm.expectRevert("POST_MISMATCH");
        adapter.handleDaAttestation(postId, keccak256("other"), kzgCommit, new address[](0), 1, 1);
    }

    function testCustodyChallengesDefaultEmpty() external {
        bytes32 postId = registry.createPost(keccak256("cid2"), keccak256("kzg2"));
        EmeraldDaAdapter.CustodyChallenge[] memory challenges = adapter.getCustodyChallenges(postId);
        assertEq(challenges.length, 0, "custody defaults empty");
    }

    function testStartCustodyChallengesCreatesEntries() external {
        bytes32 cidHash = keccak256("cid3");
        bytes32 kzgCommit = keccak256("kzg3");
        bytes32 postId = registry.createPost(cidHash, kzgCommit);
        address[] memory voters = new address[](2);
        voters[0] = address(0x1);
        voters[1] = address(0x2);
        adapter.handleDaAttestation(postId, cidHash, kzgCommit, voters, 2, 2);

        adapter.startCustodyChallenges(postId);
        EmeraldDaAdapter.CustodyChallenge[] memory challenges = adapter.getCustodyChallenges(postId);
        assertEq(challenges.length, 2, "challenges length");
        assertEq(challenges[0].operator, voters[0], "operator 0");
        assertTrue(!challenges[0].responded, "not responded");
    }

    function testStartCustodyChallengesRequiresPhase1() external {
        bytes32 postId = registry.createPost(keccak256("cid4"), keccak256("kzg4"));
        vm.expectRevert("NOT_PHASE1");
        adapter.startCustodyChallenges(postId);
    }

    function testSubmitCustodyProofMarksResponded() external {
        bytes32 cidHash = keccak256("cid5");
        bytes32 kzgCommit = keccak256("kzg5");
        bytes32 postId = registry.createPost(cidHash, kzgCommit);
        address[] memory voters = new address[](1);
        voters[0] = address(0x1);
        adapter.handleDaAttestation(postId, cidHash, kzgCommit, voters, 1, 1);
        adapter.startCustodyChallenges(postId);

        adapter.submitCustodyProof(postId, voters[0], "", "", "");
        EmeraldDaAdapter.CustodyChallenge[] memory challenges = adapter.getCustodyChallenges(postId);
        assertTrue(challenges[0].responded, "responded");
        assertTrue(challenges[0].success, "success");
    }

    function testFinalizeCustodySetsAvailableOnSuccess() external {
        bytes32 cidHash = keccak256("cid6");
        bytes32 kzgCommit = keccak256("kzg6");
        bytes32 postId = registry.createPost(cidHash, kzgCommit);
        address[] memory voters = new address[](2);
        voters[0] = address(0x1);
        voters[1] = address(0x2);
        adapter.handleDaAttestation(postId, cidHash, kzgCommit, voters, 2, 2);
        adapter.startCustodyChallenges(postId);

        adapter.submitCustodyProof(postId, voters[0], "", "", "");
        adapter.submitCustodyProof(postId, voters[1], "", "", "");
        adapter.finalizePostFromCustody(postId);
        Post memory post = registry.getPost(postId);
        assertEq(uint256(post.status), uint256(Status.Available), "available");
    }

    function testFinalizeCustodySetsUnavailableOnFailure() external {
        bytes32 cidHash = keccak256("cid7");
        bytes32 kzgCommit = keccak256("kzg7");
        bytes32 postId = registry.createPost(cidHash, kzgCommit);
        address[] memory voters = new address[](1);
        voters[0] = address(0x1);
        adapter.handleDaAttestation(postId, cidHash, kzgCommit, voters, 1, 1);
        adapter.startCustodyChallenges(postId);
        verifier.setShouldVerify(false);

        adapter.submitCustodyProof(postId, voters[0], "", "", "");
        adapter.finalizePostFromCustody(postId);
        Post memory post = registry.getPost(postId);
        assertEq(uint256(post.status), uint256(Status.Unavailable), "unavailable");
    }
}
