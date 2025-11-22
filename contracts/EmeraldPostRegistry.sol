// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./EmeraldTypes.sol";

contract EmeraldPostRegistry {
    event PostCreated(bytes32 indexed postId, bytes32 cidHash, bytes32 kzgCommit, address indexed author);
    event PostStatusChanged(bytes32 indexed postId, Status newStatus);

    address public immutable daAdapter;
    mapping(bytes32 => Post) private posts;

    constructor(address daAdapter_) {
        daAdapter = daAdapter_;
    }

    function createPost(bytes32 cidHash, bytes32 kzgCommit) external returns (bytes32 postId) {
        postId = keccak256(abi.encodePacked(msg.sender, cidHash, kzgCommit, block.number));
        require(posts[postId].postId == bytes32(0), "POST_EXISTS");

        posts[postId] = Post({postId: postId, cidHash: cidHash, kzgCommit: kzgCommit, status: Status.Pending});
        emit PostCreated(postId, cidHash, kzgCommit, msg.sender);
    }

    function getPost(bytes32 postId) external view returns (Post memory) {
        return posts[postId];
    }

    function setStatusFromDa(bytes32 postId, Status newStatus) external {
        require(msg.sender == daAdapter, "NOT_ADAPTER");
        Post storage post = posts[postId];
        require(post.postId != bytes32(0), "POST_MISSING");

        post.status = newStatus;
        emit PostStatusChanged(postId, newStatus);
    }
}
