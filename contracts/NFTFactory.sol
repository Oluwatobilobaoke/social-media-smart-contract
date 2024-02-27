// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "./NFT.sol";

contract NFTFactory {
    PostNFT[] public nftClones;

    function createNFT(
        string memory _baseURI,
        string memory _name,
        string memory _symbol,
        address _initialOwner
    ) external returns (PostNFT nft_) {
        nft_ = new PostNFT(_baseURI, _name, _symbol, _initialOwner);

        nftClones.push(nft_);
    }

    function getNFTClones() external view returns (PostNFT[] memory) {
        return nftClones;
    }
}
