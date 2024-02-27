import { loadFixture } from "@nomicfoundation/hardhat-toolbox/network-helpers";
import { expect } from "chai";
import { ethers } from "hardhat";

describe("SocialMedia", function () {
  async function deploySocialMedia() {
    const [owner, otherAccount, addr1, addr2, addr3, addr4, addr5, addr6] =
      await ethers.getSigners();

    const NFTContract = await ethers.getContractFactory("NFTFactory");
    const nftFactoryContract = await NFTContract.deploy();

    const SocialMedia = await ethers.getContractFactory("QuteeMedia");
    const socialMedia = await SocialMedia.deploy(
      owner.address,
      nftFactoryContract.target
    );

    console.log(`SocialMedia contract deployed to ${socialMedia.getAddress()}`);

    return {
      owner,
      otherAccount,
      addr1,
      addr2,
      addr3,
      addr4,
      addr5,
      addr6,
      nftFactoryContract,
      socialMedia,
    };
  }

  describe("Deployment", function () {
    it("Should be able to deploy the NFT contract", async () => {
      const { nftFactoryContract } = await loadFixture(deploySocialMedia);
      expect(nftFactoryContract.target).to.not.equal(0);
    });

    it("Should be able to deploy the SocialMedia contract", async () => {
      const { socialMedia } = await loadFixture(deploySocialMedia);
      expect(socialMedia.target).to.not.equal(0);
    });
  });

  describe("Register", function () {
    it("Should be able to register a new user", async () => {
      const { socialMedia, addr1 } = await loadFixture(deploySocialMedia);
      await socialMedia.connect(addr1).registerUser();
      // check if user is registered
      expect(await socialMedia.isUserRegistered(addr1.address)).to.equal(true);
    });
  });

  describe("Create Post", function () {
    it("Should be able to create a new post", async () => {
      const { socialMedia, addr1 } = await loadFixture(deploySocialMedia);

      // register user
      await socialMedia.connect(addr1).registerUser();

      const postText = "Hello World";
      const postImage = "https://example.com/image.jpg";
      const postName = "My Post";

      await socialMedia
        .connect(addr1)
        .createPost(postText, postImage, postName);

      expect(await socialMedia.nextPostId()).to.equal(1);
    });

    it("Should be able to create a new post and search for the post details", async () => {
      const { socialMedia, addr1 } = await loadFixture(deploySocialMedia);

      // register user
      await socialMedia.connect(addr1).registerUser();

      const postText = "Hello World";
      const postImage = "https://example.com/image.jpg";
      const postName = "My Post";

      await socialMedia
        .connect(addr1)
        .createPost(postText, postImage, postName);

      const post = await socialMedia.searchPost(0);
      expect(post.text).to.equal(postText);
      expect(post.postOwner).to.equal(addr1.address);
      expect(post.postId).to.equal(0);
    });

    it("Should be able to create new posts and get posts", async () => {
      const { socialMedia, addr1, addr2, addr3, addr4 } = await loadFixture(
        deploySocialMedia
      );

      // register user
      await socialMedia.connect(addr1).registerUser();
      await socialMedia.connect(addr2).registerUser();
      await socialMedia.connect(addr3).registerUser();

      const postText = "Hello World";
      const postImage = "https://example.com/image.jpg";
      const postName = "My Post";

      await socialMedia
        .connect(addr1)
        .createPost(postText, postImage, postName);

      await socialMedia
        .connect(addr2)
        .createPost(postText, postImage, postName);
      await socialMedia
        .connect(addr3)
        .createPost(postText, postImage, postName);

      const post = await socialMedia.fetchPosts();
      expect(post[0].text).to.equal(postText);
      expect(post[0].postOwner).to.equal(addr1.address);
      expect(post[0].postId).to.equal(0);
      expect(post.length).to.equal(3);
    });

    it("Should be able to create new posts and upvote", async () => {
      const { socialMedia, addr1, addr2, addr3, addr4 } = await loadFixture(
        deploySocialMedia
      );

      // register user
      await socialMedia.connect(addr1).registerUser();
      await socialMedia.connect(addr2).registerUser();
      await socialMedia.connect(addr3).registerUser();
      await socialMedia.connect(addr4).registerUser();

      const postText = "Hello World";
      const postImage = "https://example.com/image.jpg";
      const postName = "My Post";

      await socialMedia
        .connect(addr1)
        .createPost(postText, postImage, postName);

      await socialMedia.connect(addr2).VotePost(0);
      await socialMedia.connect(addr3).VotePost(0);
      await socialMedia.connect(addr4).VotePost(0);

      const post = await socialMedia.searchPost(0);
      expect(post.upvote).to.equal(3);
    });

    it("Should be able to create new posts and downvote", async () => {
      const { socialMedia, addr1, addr2, addr3, addr4, addr5, addr6} = await loadFixture(
        deploySocialMedia
      );

      // register user
      await socialMedia.connect(addr1).registerUser();
      await socialMedia.connect(addr2).registerUser();
      await socialMedia.connect(addr3).registerUser();
      await socialMedia.connect(addr4).registerUser();

      const postText = "Hello World";
      const postImage = "https://example.com/image.jpg";
      const postName = "My Post";

      await socialMedia
        .connect(addr1)
        .createPost(postText, postImage, postName);

      await socialMedia.connect(addr2).VotePost(0);
      await socialMedia.connect(addr3).VotePost(0);
      await socialMedia.connect(addr4).VotePost(0);

      await socialMedia.connect(addr5).downVoteCourse(0);
      await socialMedia.connect(addr6).downVoteCourse(0);


      const post = await socialMedia.searchPost(0);
      expect(post.downvote).to.equal(2);
      expect(post.upvote).to.equal(3);
    });
  });
});
