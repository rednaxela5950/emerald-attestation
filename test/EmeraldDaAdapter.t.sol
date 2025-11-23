// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../contracts/EmeraldDaAdapter.sol";
import "../contracts/EmeraldPostRegistry.sol";
import "../contracts/EmeraldTypes.sol";
import "./TestBase.sol";

contract EmeraldDaAdapterTest is TestBase {
    EmeraldPostRegistry private registry;
    EmeraldDaAdapter private adapter;

    function setUp() external {
        adapter = new EmeraldDaAdapter(EmeraldPostRegistry(address(0)));
        registry = new EmeraldPostRegistry(address(adapter));
        adapter.setRegistry(registry);
    }

    function testHandlePhase1ResultUpdatesRegistryAndState() external {
        bytes32 cidHash = keccak256("cid");
        bytes32 kzgCommit = keccak256("kzg");
        bytes32 postId = registry.createPost(cidHash, kzgCommit);
        address[] memory voters = new address[](1);
        voters[0] = address(0x1);
        adapter.handlePhase1Result(postId, cidHash, kzgCommit, voters, 2, 3, true);
        Post memory post = registry.getPost(postId);
        assertEq(uint256(post.status), uint256(Status.Phase1Passed), "status");
        EmeraldDaAdapter.Phase1State memory state = adapter.getPhase1State(postId);
        assertEq(state.yesStake, 2, "yesStake");
        assertEq(state.totalStake, 3, "totalStake");
        assertEq(state.yesVoters.length, 1, "voters length");
    }
}
