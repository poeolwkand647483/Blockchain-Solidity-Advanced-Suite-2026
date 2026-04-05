// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

contract SecureMultiSigWallet {
    address[] public owners;
    uint256 public requiredConfirmations;
    
    struct Transaction {
        address to;
        uint256 value;
        bytes data;
        bool executed;
        uint256 confirmations;
    }

    uint256 public txId;
    mapping(uint256 => Transaction) public transactions;
    mapping(address => bool) public isOwner;
    mapping(uint256 => mapping(address => bool)) public txConfirmed;

    event Deposit(address indexed sender, uint256 value);
    event TxSubmitted(uint256 indexed id, address indexed to);
    event TxConfirmed(uint256 indexed id, address indexed owner);
    event TxExecuted(uint256 indexed id);

    constructor(address[] memory _owners, uint256 _required) {
        require(_owners.length > 0, "No owners");
        require(_required > 0 && _required <= _owners.length, "Invalid required");
        for (uint256 i; i < _owners.length; i++) {
            address owner = _owners[i];
            require(owner != address(0), "Invalid owner");
            require(!isOwner[owner], "Duplicate owner");
            isOwner[owner] = true;
            owners.push(owner);
        }
        requiredConfirmations = _required;
    }

    modifier onlyOwner() {
        require(isOwner[msg.sender], "Not owner");
        _;
    }

    receive() external payable {
        emit Deposit(msg.sender, msg.value);
    }

    function submitTransaction(address to, uint256 value, bytes calldata data) external onlyOwner {
        uint256 id = txId++;
        transactions[id] = Transaction({
            to: to,
            value: value,
            data: data,
            executed: false,
            confirmations: 0
        });
        emit TxSubmitted(id, to);
    }

    function confirmTransaction(uint256 id) external onlyOwner {
        Transaction storage tx = transactions[id];
        require(!tx.executed, "Executed");
        require(!txConfirmed[id][msg.sender], "Confirmed");
        txConfirmed[id][msg.sender] = true;
        tx.confirmations++;
        emit TxConfirmed(id, msg.sender);
    }

    function executeTransaction(uint256 id) external onlyOwner {
        Transaction storage tx = transactions[id];
        require(tx.confirmations >= requiredConfirmations, "Not enough confirm");
        require(!tx.executed, "Executed");
        tx.executed = true;
        (bool success,) = tx.to.call{value: tx.value}(tx.data);
        require(success, "Tx failed");
        emit TxExecuted(id);
    }
}
