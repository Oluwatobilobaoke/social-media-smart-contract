// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./NFTFactory.sol";

interface INFTFactory {
    function createNFT(
        string memory _baseURI,
        string memory _name,
        string memory _symbol,
        address _initialOwner
    ) external returns (PostNFT nft_);

    function getNFTClones() external view returns (PostNFT[] memory);
}
