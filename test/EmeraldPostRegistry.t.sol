// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../contracts/EmeraldPostRegistry.sol";
import "../contracts/EmeraldTypes.sol";
import "./TestBase.sol";

contract AdapterStub {
    function setStatus(EmeraldPostRegistry registry, bytes32 postId, Status newStatus) external {
        registry.setStatusFromDa(postId, newStatus);
    }
}

contract EmeraldPostRegistryTest is TestBase {
    EmeraldPostRegistry private registry;
    AdapterStub private adapter;

    function setUp() external {
        adapter = new AdapterStub();
        registry = new EmeraldPostRegistry(address(adapter));
    }

    function testCreatePostStoresFields() external {
        bytes32 cidHash = keccak256("cid");
        bytes32 kzgCommit = keccak256("kzg");

        bytes32 postId = registry.createPost(cidHash, kzgCommit);
        Post memory post = registry.getPost(postId);

        assertEq(post.postId, postId, "postId mismatch");
        assertEq(post.cidHash, cidHash, "cidHash mismatch");
        assertEq(post.kzgCommit, kzgCommit, "kzgCommit mismatch");
        assertEq(uint256(post.status), uint256(Status.Pending), "status should be pending");
    }

    function testSetStatusFromDaUpdatesStatus() external {
        bytes32 cidHash = keccak256("cid");
        bytes32 kzgCommit = keccak256("kzg");
        bytes32 postId = registry.createPost(cidHash, kzgCommit);

        adapter.setStatus(registry, postId, Status.Available);
        Post memory post = registry.getPost(postId);

        assertEq(uint256(post.status), uint256(Status.Available), "status should change");
    }

    function testSetStatusFromDaRejectsNonAdapter() external {
        bytes32 cidHash = keccak256("cid");
        bytes32 kzgCommit = keccak256("kzg");
        bytes32 postId = registry.createPost(cidHash, kzgCommit);

        vm.expectRevert("NOT_ADAPTER");
        registry.setStatusFromDa(postId, Status.Available);
    }
}
