// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract MetaTxContract {
    using ECDSA for bytes32;

    // Address of the off-chain relayer service
    address public relayer;

    // Mapping to store nonces for each user (optional, for replay protection)
    mapping(address => uint256) public nonces;

    constructor(address _relayer) {
        relayer = _relayer;
    }

    function executeMetaTx(
        address userAddress,
        bytes memory functionCall,
        bytes memory signature,
        uint256 nonce // optional, for replay protection
    ) external returns (bytes memory) {
        require(msg.sender == relayer, "Only relayer can execute");

        // Verify signature and recover signer address
        address signer = getSigner(userAddress, functionCall, signature, nonce);
        require(signer == userAddress, "Invalid signature");

        // Additional check for nonce if implemented
        if (nonces[userAddress] != nonce) {
            revert("Invalid nonce");
        }

        // Execute the actual function call
        (bool success, bytes memory data) = address(this).call(functionCall);
        require(success, "Function call failed");

        // Update nonce if used
        nonces[userAddress]++;

        return data;
    }

    // Helper function to get the signer address (replace with your logic for nonce handling)
    function getSigner(
        address userAddress,
        bytes memory functionCall,
        bytes memory signature,
        uint256 nonce
    ) internal pure returns (address) {
        bytes32 hash = keccak256(
            abi.encodePacked(
                "\x19Ethereum Signed Message:\n32",
                keccak256(abi.encodePacked(userAddress, functionCall, nonce))
            )
        );
        return hash.recover(signature);
    }
}
