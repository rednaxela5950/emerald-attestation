// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./EmeraldPostRegistry.sol";
import "./EmeraldTypes.sol";
import "./MockKzgVerifier.sol";

contract EmeraldDaAdapter {
    struct Phase1State { uint256 yesStake; uint256 totalStake; address[] yesVoters; }
    struct CustodyChallenge { address operator; uint256 challengeIndex; bool responded; bool success; }

    event Phase1DaPassed(bytes32 indexed postId, uint256 yesStake, uint256 totalStake);
    event Phase1DaFailed(bytes32 indexed postId, uint256 yesStake, uint256 totalStake);
    event CustodyChallengeStarted(bytes32 indexed postId, address indexed operator, uint256 challengeIndex);
    event CustodyProofSubmitted(bytes32 indexed postId, address indexed operator, bool success);
    event PostFinalized(bytes32 indexed postId, Status finalStatus);

    EmeraldPostRegistry public registry;
    address public relay;
    MockKzgVerifier public verifier;
    mapping(bytes32 => Phase1State) private phase1States;
    mapping(bytes32 => CustodyChallenge[]) private custodyChallenges;

    constructor(EmeraldPostRegistry registry_, address relay_, MockKzgVerifier verifier_) {
        registry = registry_;
        relay = relay_;
        verifier = verifier_;
    }

    function setRegistry(EmeraldPostRegistry registry_) external {
        require(address(registry) == address(0), "REGISTRY_SET");
        registry = registry_;
    }

    function handleDaAttestation(bytes32 postId, bytes32 cidHash, bytes32 kzgCommit, address[] calldata yesVoters, uint256 yesStake, uint256 totalStake) external onlyRelay {
        require(address(registry) != address(0), "REGISTRY_MISSING");
        Post memory post = registry.getPost(postId);
        require(post.postId != bytes32(0), "POST_MISSING");
        require(post.cidHash == cidHash && post.kzgCommit == kzgCommit, "POST_MISMATCH");
        require(yesStake > 0 && totalStake > 0, "STAKE_ZERO");

        bool passed = _passesThreshold(yesStake, totalStake);
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

    function _passesThreshold(uint256 yesStake, uint256 totalStake) private pure returns (bool) {
        return yesStake >= (totalStake + 1) / 2;
    }

    function startCustodyChallenges(bytes32 postId) external {
        Post memory post = registry.getPost(postId);
        require(post.status == Status.Phase1Passed, "NOT_PHASE1");
        require(custodyChallenges[postId].length == 0, "ALREADY_STARTED");

        Phase1State storage state = phase1States[postId];
        uint256 votersLen = state.yesVoters.length;
        require(votersLen > 0, "NO_VOTERS");

        for (uint256 i = 0; i < votersLen; i++) {
            address operator = state.yesVoters[i];
            uint256 challengeIndex = uint256(keccak256(abi.encodePacked(postId, operator, i)));
            custodyChallenges[postId].push(CustodyChallenge(operator, challengeIndex, false, false));
            emit CustodyChallengeStarted(postId, operator, challengeIndex);
        }
    }

    function submitCustodyProof(bytes32 postId, address operator, bytes calldata x, bytes calldata y, bytes calldata pi) external {
        CustodyChallenge[] storage challenges = custodyChallenges[postId];
        require(challenges.length > 0, "NO_CHALLENGES");

        uint256 idx = _findChallengeIndex(challenges, operator);
        CustodyChallenge storage challenge = challenges[idx];
        require(!challenge.responded, "ALREADY_RESPONDED");

        bool ok = verifier.verifyKzgOpening(x, y, pi);
        challenge.responded = true;
        challenge.success = ok;
        emit CustodyProofSubmitted(postId, operator, ok);
    }

    modifier onlyRelay() {
        require(msg.sender == relay, "NOT_RELAY");
        _;
    }

    function _findChallengeIndex(CustodyChallenge[] storage challenges, address operator) private view returns (uint256) {
        for (uint256 i = 0; i < challenges.length; i++) {
            if (challenges[i].operator == operator) return i;
        }
        revert("CHALLENGE_MISSING");
    }
}
