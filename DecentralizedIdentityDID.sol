// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

contract DecentralizedIdentityDID {
    struct DIDDocument {
        string publicKey;
        string profileURI;
        bool isActive;
        uint256 created;
    }

    mapping(address => DIDDocument) public dids;
    mapping(string => address) public usernameToAddress;

    event DIDCreated(address indexed user, string username);
    event DIDUpdated(address indexed user, string newKey, string newURI);
    event DIDDeactivated(address indexed user);

    function createDID(string calldata username, string calldata pubKey, string calldata uri) external {
        require(dids[msg.sender].created == 0, "DID exists");
        require(usernameToAddress[username] == address(0), "Username taken");
        dids[msg.sender] = DIDDocument({
            publicKey: pubKey,
            profileURI: uri,
            isActive: true,
            created: block.timestamp
        });
        usernameToAddress[username] = msg.sender;
        emit DIDCreated(msg.sender, username);
    }

    function updateDID(string calldata newKey, string calldata newURI) external {
        require(dids[msg.sender].created > 0, "DID not exist");
        dids[msg.sender].publicKey = newKey;
        dids[msg.sender].profileURI = newURI;
        emit DIDUpdated(msg.sender, newKey, newURI);
    }

    function deactivateDID() external {
        dids[msg.sender].isActive = false;
        emit DIDDeactivated(msg.sender);
    }
}
