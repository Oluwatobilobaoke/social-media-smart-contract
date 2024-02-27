// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// import openzeppelin contracts for RBAC
import "@openzeppelin/contracts/access/AccessControl.sol";
import "./INFTFactory.sol";
import "./NFT.sol";

error YOU_ARE_NOT_ADMIN();
error YOU_ARE_NOT_USER();
error YOU_ARE_NOT_GROUP_OWNER();

contract QuteeMedia is AccessControl {
    INFTFactory nftFactoryInstance;

    // Create a new role identifier for the role
    bytes32 constant USER_ROLE = keccak256("USER");
    event AdminRoleSet(bytes32 roleId, bytes32 adminRoleId);

    uint private nextPostId;

    struct Post {
        uint256 postId;
        address postOwner;
        string text;
        uint256 upvote;
        uint256 downvote;
        uint256 views;
        PostNFT nft;
        uint createdAt;
    }

    // group struct with post and member
    struct Group {
        uint256 groupId;
        address groupOwner;
        string name;
        string description;
        uint256 memberCount;
        address[] memberCounts;
        uint256[] groupPosts;
        uint createdAt;
    }

    Group[] public allGroups;

    Post[] public allPosts;

    event Vote(uint256 postId, address user);

    event Register(address user);

    event NewPostUpdate(uint256 postId, address postOwner, string text);

    mapping(uint256 => Post) public posts;
    mapping(uint256 => Group) public groups;
    mapping(address => uint[]) private postOf;
    mapping(address => mapping(uint256 => bool)) public idToVote;

    // Define the role for the admin
    constructor(address defaultAdmin, address _nftFactory) {
        _grantRole(DEFAULT_ADMIN_ROLE, defaultAdmin);
        nftFactoryInstance = INFTFactory(_nftFactory);
    }

    // register a new user
    function registerUser(address user) external {
        _grantRole(USER_ROLE, user);
        emit Register(user);
    }

    // create a new post
    function createPost(
        string memory text,
        string memory baseURI,
        string memory name
    ) external onlyUser {
        // create a new NFT with factory contract and store the address of the NFT in the post
        PostNFT mintedNft = nftFactoryInstance.createNFT(
            baseURI,
            name,
            "QUTE",
            msg.sender
        );

        Post memory post = Post(
            nextPostId,
            msg.sender,
            text,
            0,
            0,
            0,
            mintedNft,
            block.timestamp
        );
        posts[nextPostId] = post;
        allPosts.push(post);
        postOf[msg.sender].push(nextPostId);
        nextPostId++;
        emit NewPostUpdate(post.postId, post.postOwner, post.text);
    }

    // upvote a post or downvote a post
    function VotePost(uint256 postId) external onlyUser {
        // look up post
        Post storage post = posts[postId];

        if (idToVote[msg.sender][postId] == false) {
            post.upvote = post.upvote + 1;
            idToVote[msg.sender][postId] = true;
        } else {
            post.upvote = post.upvote - 1;
            idToVote[msg.sender][postId] = false;
        }

        // update post view
        post.views = post.views + 1;

        emit Vote(postId, msg.sender);
    }

    function fetchPosts() public view returns (Post[] memory) {
        uint256 currentIndex = 0;

        Post[] memory items = new Post[](nextPostId);

        for (uint256 i = 0; i < nextPostId; i++) {
            uint256 currentId = i;

            Post storage currentItem = posts[currentId];
            items[currentIndex] = currentItem;

            currentIndex += 1;
        }
        return items;
    }

    //create a new group
    function createGroup(
        string memory name,
        string memory description
    ) external onlyUser {
        Group memory group = Group(
            allGroups.length,
            msg.sender,
            name,
            description,
            1,
            new address[](0),
            new uint256[](0),
            block.timestamp
        );
        groups[allGroups.length] = group;
        allGroups.push(group);
    }

    // add a member to a group
    function addMemberToGroup(
        uint256 groupId,
        address member
    ) external onlyUser {
        Group storage group = groups[groupId];
        group.memberCounts.push(member);
        group.memberCount = group.memberCount + 1;
    }

    // remove a member from a group
    function removeMemberFromGroup(
        uint256 groupId,
        address member
    ) external onlyUser {
        Group storage group = groups[groupId];
        // check if mesg.sender is the owner of the group
        if (group.groupOwner != msg.sender) revert YOU_ARE_NOT_GROUP_OWNER();
        for (uint i = 0; i < group.memberCounts.length; i++) {
            if (group.memberCounts[i] == member) {
                delete group.memberCounts[i];
                group.memberCount = group.memberCount - 1;
            }
        }
    }

    // make a post in a group
    function makePostInGroup(
        uint256 groupId,
        string memory text,
        string memory baseURI,
        string memory name
    ) external onlyUser {
        // create a new NFT with factory contract and store the address of the NFT in the post
        PostNFT mintedNft = nftFactoryInstance.createNFT(
            baseURI,
            name,
            "QUTE",
            msg.sender
        );

        Post memory post = Post(
            nextPostId,
            msg.sender,
            text,
            0,
            0,
            0,
            mintedNft,
            block.timestamp
        );
        posts[nextPostId] = post;
        allPosts.push(post);
        postOf[msg.sender].push(nextPostId);
        nextPostId++;
        Group storage group = groups[groupId];
        group.groupPosts.push(post.postId);
    }

    // group owner delete a post
    function deletePostInGroup(
        uint256 groupId,
        uint256 postId
    ) external onlyUser {
        Group storage group = groups[groupId];
        // check if mesg.sender is the owner of the group
        if (group.groupOwner != msg.sender) revert YOU_ARE_NOT_GROUP_OWNER();
        delete posts[postId];
    }

    // search for a post
    function searchPost(uint256 postId) external view returns (Post memory) {
        return posts[postId];
    }

    // admin delete a post
    function deletePost(uint256 postId) external onlyAdmin {
        delete posts[postId];
    }

    // @dev Restricted to members of the admin role.
    modifier onlyAdmin() {
        if (!isAdmin(msg.sender)) revert YOU_ARE_NOT_ADMIN();
        _;
    }

    // @dev Restricted to members of the user role.
    modifier onlyUser() {
        if (!isUser(msg.sender)) revert YOU_ARE_NOT_USER();
        _;
    }

    /// @dev Return `true` if the account belongs to the admin role.
    function isAdmin(address account) private view returns (bool) {
        return hasRole(DEFAULT_ADMIN_ROLE, account);
    }

    /// @dev Return `true` if the account belongs to the user role.
    function isUser(address account) private view returns (bool) {
        return hasRole(USER_ROLE, account);
    }

    /// @dev Add an account to the admin role. Restricted to admins.
    function addAdmin(address account) external virtual onlyAdmin {
        grantRole(DEFAULT_ADMIN_ROLE, account);
    }

    /// @dev Remove an account from the user role. Restricted to admins.
    function removeUser(address account) external virtual onlyAdmin {
        revokeRole(USER_ROLE, account);
    }

    /// @dev Remove oneself from the admin role.
    function renounceAdmin() external virtual {
        renounceRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }
}
