// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../contracts/EmeraldPostRegistry.sol";
import "../contracts/EmeraldTypes.sol";
import "./TestBase.sol";

contract EmeraldPostRegistryTest is TestBase {
    EmeraldPostRegistry private registry;

    function setUp() external {
        registry = new EmeraldPostRegistry(address(0xBEEF));
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
}
