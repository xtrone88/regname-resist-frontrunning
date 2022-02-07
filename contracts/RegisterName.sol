// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

contract RegisterName is Ownable {

    struct RegState {
        address owner;
        uint256 transactionId;
        uint256 lockTime;
        uint256 balance;
    }

    uint256 private transactionCount;
    uint256 private currentTransaction;
    uint256 private totalFeeBalance;
    mapping(address => uint256) private transactionOrders;
    mapping(bytes32 => RegState) private registeredStates;
    mapping(address => uint256) private unlockedBalances;

    constructor() {
        
    }

    event Registered(string name, uint256 transactionId);

    function newTransactionId() public {
        transactionCount++;
        transactionOrders[msg.sender] = transactionCount;
    }

    function getTransactionId() public view returns (uint256) {
        return transactionOrders[msg.sender];
    }

    function getRegState(string memory name) public view returns(RegState memory) {
        return registeredStates[keccak256(bytes(name))];
    }

    function getTotalFeeBalance() public view returns(uint256) {
        return totalFeeBalance;
    }

    function getUnlockedBalance() public view returns(uint256) {
        return unlockedBalances[msg.sender];
    }

    function registerName(string memory name) public payable {
        require(currentTransaction + 1 == transactionOrders[msg.sender], "Invalid ordered transaction");
        currentTransaction++;
        uint256 fee = bytes(name).length * 1000 gwei;
        require(msg.value > fee, "Not enough fee");

        bytes32 hashOfName = keccak256(bytes(name));
        RegState memory regState = registeredStates[hashOfName];

        if (regState.transactionId > 0) {
            require(regState.lockTime < block.timestamp, "Not unlocked name");
            if (regState.owner != msg.sender) {
                unlockedBalances[regState.owner] += regState.balance;
                regState.owner = msg.sender;
                regState.balance = 0;
            }
            regState.transactionId = transactionOrders[msg.sender];
            regState.lockTime = block.timestamp + 1 seconds;
            regState.balance += msg.value - fee;
            registeredStates[hashOfName] = regState;
        } else {
            registeredStates[hashOfName] = RegState(msg.sender, transactionOrders[msg.sender], block.timestamp + 1 seconds, msg.value - fee);
        }
        totalFeeBalance += fee;
        
        emit Registered(name, transactionOrders[msg.sender]);
    }

    function withraw(string memory name) public payable {
        bytes32 hashOfName = keccak256(bytes(name));
        RegState memory regState = registeredStates[hashOfName];
        require(regState.transactionId > 0, "Invalid name");

        uint256 amount = 0;
        if (regState.owner == msg.sender) {
            require(regState.lockTime < block.timestamp, "Not unlocked name");
            amount = regState.balance;
            registeredStates[hashOfName] = RegState(address(0), 0, 0, 0);
        } else {
            amount = unlockedBalances[msg.sender];
            unlockedBalances[msg.sender] = 0;
        }
        
        (bool withrawn, ) = msg.sender.call{value: amount}("");
        require(withrawn, "Transfer balance failed");
    }

    function withrawFee() public payable onlyOwner {
        totalFeeBalance = 0;
        (bool withrawn, ) = msg.sender.call{value: totalFeeBalance}("");
        require(withrawn, "Transfer balance failed");
    }
}