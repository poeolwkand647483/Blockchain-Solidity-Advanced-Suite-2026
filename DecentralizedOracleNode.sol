// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

contract DecentralizedOracleNode {
    struct DataRequest {
        address requester;
        string query;
        uint256 reward;
        bool fulfilled;
    }

    uint256 public requestId;
    mapping(uint256 => DataRequest) public requests;
    mapping(uint256 => mapping(address => string)) public responses;
    mapping(uint256 => address[]) public responders;

    event RequestCreated(uint256 indexed id, string query, uint256 reward);
    event ResponseSubmitted(uint256 indexed id, address node, string data);
    event RequestFulfilled(uint256 indexed id, string result);

    function createRequest(string calldata query) external payable {
        require(msg.value > 0, "No reward");
        uint256 id = requestId++;
        requests[id] = DataRequest({
            requester: msg.sender,
            query: query,
            reward: msg.value,
            fulfilled: false
        });
        emit RequestCreated(id, query, msg.value);
    }

    function submitResponse(uint256 id, string calldata data) external {
        DataRequest storage req = requests[id];
        require(!req.fulfilled, "Fulfilled");
        responses[id][msg.sender] = data;
        responders[id].push(msg.sender);
        emit ResponseSubmitted(id, msg.sender, data);
    }

    function fulfillRequest(uint256 id, address selectedNode) external {
        DataRequest storage req = requests[id];
        require(msg.sender == req.requester, "Not requester");
        require(!req.fulfilled, "Fulfilled");
        req.fulfilled = true;
        payable(selectedNode).transfer(req.reward);
        emit RequestFulfilled(id, responses[id][selectedNode]);
    }
}
