// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

contract BlockchainSignatureValidator {
    function verifySignature(
        address signer,
        bytes32 hash,
        bytes32 r,
        bytes32 s,
        uint8 v
    ) external pure returns (bool) {
        bytes32 digest = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
        return ecrecover(digest, v, r, s) == signer;
    }

    function getMessageHash(string calldata message) external pure returns (bytes32) {
        return keccak256(bytes(message));
    }
}
