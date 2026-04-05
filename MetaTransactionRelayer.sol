// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

contract MetaTransactionRelayer {
    mapping(address => uint256) public nonces;

    event MetaTransactionExecuted(address indexed user, address indexed relayer, bytes data);

    function executeMetaTransaction(
        address user,
        bytes calldata data,
        bytes32 r,
        bytes32 s,
        uint8 v
    ) external returns (bool, bytes memory) {
        bytes32 digest = keccak256(abi.encodePacked(
            "\x19Ethereum Signed Message:\n32",
            keccak256(abi.encodePacked(user, nonces[user], address(this), data))
        ));
        address signer = ecrecover(digest, v, r, s);
        require(signer == user && signer != address(0), "Invalid signature");
        nonces[user]++;
        (bool success, bytes memory result) = address(this).call(abi.encodePacked(data, user));
        emit MetaTransactionExecuted(user, msg.sender, data);
        return (success, result);
    }
}
