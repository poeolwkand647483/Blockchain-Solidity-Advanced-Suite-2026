// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

contract EliteERC20GovernanceToken {
    string public constant name = "Elite Governance Token";
    string public constant symbol = "EGT";
    uint8 public constant decimals = 18;
    uint256 public totalSupply;
    
    mapping(address => uint256) public balances;
    mapping(address => mapping(address => uint256)) public allowances;
    mapping(address => bool) public isGovernor;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event GovernorAdded(address indexed account);
    event GovernorRemoved(address indexed account);

    constructor(uint256 _initialSupply) {
        totalSupply = _initialSupply * 10 ** decimals;
        balances[msg.sender] = totalSupply;
        isGovernor[msg.sender] = true;
        emit Transfer(address(0), msg.sender, totalSupply);
    }

    modifier onlyGovernor() {
        require(isGovernor[msg.sender], "Not governor");
        _;
    }

    function transfer(address to, uint256 amount) external returns (bool) {
        require(balances[msg.sender] >= amount, "Insufficient balance");
        balances[msg.sender] -= amount;
        balances[to] += amount;
        emit Transfer(msg.sender, to, amount);
        return true;
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) external returns (bool) {
        require(allowances[from][msg.sender] >= amount, "Allowance exceeded");
        require(balances[from] >= amount, "Insufficient balance");
        allowances[from][msg.sender] -= amount;
        balances[from] -= amount;
        balances[to] += amount;
        emit Transfer(from, to, amount);
        return true;
    }

    function addGovernor(address account) external onlyGovernor {
        isGovernor[account] = true;
        emit GovernorAdded(account);
    }

    function removeGovernor(address account) external onlyGovernor {
        isGovernor[account] = false;
        emit GovernorRemoved(account);
    }
}
