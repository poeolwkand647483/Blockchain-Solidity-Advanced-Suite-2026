// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/access/Ownable.sol";

contract DAOProposalVotingSystem is Ownable {
    struct Proposal {
        string title;
        string description;
        uint256 voteFor;
        uint256 voteAgainst;
        uint256 endTime;
        bool executed;
    }

    uint256 public proposalId;
    mapping(uint256 => Proposal) public proposals;
    mapping(address => mapping(uint256 => bool)) public hasVoted;
    uint256 public votingPeriod = 3 days;

    event ProposalCreated(uint256 indexed id, string title);
    event Voted(uint256 indexed id, address indexed voter, bool support);
    event ProposalExecuted(uint256 indexed id);

    constructor() Ownable(msg.sender) {}

    function createProposal(string calldata title, string calldata desc) external onlyOwner {
        uint256 id = proposalId++;
        proposals[id] = Proposal({
            title: title,
            description: desc,
            voteFor: 0,
            voteAgainst: 0,
            endTime: block.timestamp + votingPeriod,
            executed: false
        });
        emit ProposalCreated(id, title);
    }

    function vote(uint256 id, bool support) external {
        Proposal storage prop = proposals[id];
        require(block.timestamp < prop.endTime, "Voting ended");
        require(!hasVoted[msg.sender][id], "Voted already");
        hasVoted[msg.sender][id] = true;
        if (support) prop.voteFor++;
        else prop.voteAgainst++;
        emit Voted(id, msg.sender, support);
    }

    function executeProposal(uint256 id) external onlyOwner {
        Proposal storage prop = proposals[id];
        require(block.timestamp >= prop.endTime, "Voting active");
        require(!prop.executed, "Executed");
        prop.executed = true;
        emit ProposalExecuted(id);
    }
}
