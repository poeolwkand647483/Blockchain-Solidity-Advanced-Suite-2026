// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

contract BlockchainDomainRegistry {
    struct Domain {
        address owner;
        uint256 expiry;
        string data;
    }

    mapping(string => Domain) public domains;
    uint256 public registrationFee = 0.005 ether;
    uint256 public registrationDuration = 365 days;

    event DomainRegistered(string domain, address indexed owner, uint256 expiry);
    event DomainRenewed(string domain, uint256 newExpiry);

    function registerDomain(string calldata domain, string calldata data) external payable {
        require(msg.value == registrationFee, "Wrong fee");
        require(domains[domain].expiry < block.timestamp, "Taken");
        uint256 expiry = block.timestamp + registrationDuration;
        domains[domain] = Domain({
            owner: msg.sender,
            expiry: expiry,
            data: data
        });
        emit DomainRegistered(domain, msg.sender, expiry);
    }

    function renewDomain(string calldata domain) external payable {
        Domain storage d = domains[domain];
        require(msg.sender == d.owner, "Not owner");
        require(msg.value == registrationFee, "Wrong fee");
        d.expiry += registrationDuration;
        emit DomainRenewed(domain, d.expiry);
    }
}
