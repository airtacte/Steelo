// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

interface ILens {
    /**
     * @dev Emitted when a wallet follows a new profile.
     * @param follower Address of the follower wallet.
     * @param profileId The ID of the profile being followed.
     */
    event Followed(address indexed follower, uint256 profileId);

    /**
     * @dev Emitted when a wallet likes a post.
     * @param liker Address of the liker wallet.
     * @param postId The ID of the post being liked.
     */
    event Liked(address indexed liker, uint256 postId);

    /**
     * @dev Emitted when a wallet shares a post.
     * @param sharer Address of the sharer wallet.
     * @param originalPostId The ID of the original post.
     * @param sharedPostId The ID of the shared post.
     */
    event Shared(address indexed sharer, uint256 originalPostId, uint256 sharedPostId);

    /**
     * @dev Emitted when a wallet collects a post as an NFT.
     * @param collector Address of the collector wallet.
     * @param postId The ID of the post being collected.
     * @param nftId The ID of the NFT created from the post.
     */
    event Collected(address indexed collector, uint256 postId, uint256 nftId);

    /**
     * @notice Follow a profile on Lens Protocol.
     * @param profileId The ID of the profile to follow.
     */
    function follow(uint256 profileId) external;

    /**
     * @notice Like a post on Lens Protocol.
     * @param postId The ID of the post to like.
     */
    function like(uint256 postId) external;

    /**
     * @notice Share a post on Lens Protocol.
     * @param originalPostId The ID of the post to share.
     * @return The ID of the new post created as a result of sharing.
     */
    function share(uint256 originalPostId) external returns (uint256);

    /**
     * @notice Collect a post on Lens Protocol as an NFT.
     * @param postId The ID of the post to collect.
     * @return The ID of the NFT created from the post.
     */
    function collect(uint256 postId) external returns (uint256);
}