// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @dev You can use this contract to register name with a certain balance and withraw unlocked fund after a certain period. This is implemented considering frontrunning.
 */
contract RegisterName is Ownable {

    /**
     * The information representing the registered with name
     */
    struct RegState {
        /// The owner's address
        address owner;
        /// The transaction id when registered
        uint256 transactionId;
        /// The timestamp until the locked period expires
        uint256 lockTime;
        /// The locked fund
        uint256 balance;
    }

    /// The current transaction id
    uint256 private transactionCount;
    /// The current transaction id used when the registerName is called
    uint256 private currentTransaction;
    /// The total fee
    uint256 private totalFeeBalance;
    /// The current transaction id of an account
    mapping(address => uint256) private transactionOrders;
    /// The registered status of the name
    mapping(bytes32 => RegState) private registeredStates;
    /// The unlocked fund of an account
    mapping(address => uint256) private unlockedBalances;

    constructor() {
        
    }

    /**
     * @dev Emitted when a new name is registered
     */
    event Registered(string name, uint256 transactionId);

    /**
     * @dev Generate new transaction id before registration. This must be called everytime when you are going to register name.
     */
    function newTransactionId() public {
        transactionCount++;
        transactionOrders[msg.sender] = transactionCount;
    }

    /**
     * @dev Get the current transaction id assigned to the sender.
     */
    function getTransactionId() public view returns (uint256) {
        return transactionOrders[msg.sender];
    }

    /**
     * @dev Get the registered information of name
     */
    function getRegState(string memory name) public view returns(RegState memory) {
        return registeredStates[keccak256(bytes(name))];
    }

    /**
     * @dev Get the total fee
     */
    function getTotalFeeBalance() public view returns(uint256) {
        return totalFeeBalance;
    }

    /**
     * @dev Get the unlocked fund of the sender
     */
    function getUnlockedBalance() public view returns(uint256) {
        return unlockedBalances[msg.sender];
    }

    /**
     * @dev Register name with certain amount of fund to be locked for a certain period.
     * First fo all, you have to generate new transaction id by calling newTransactionId because avoid front-running attack.
     * You have to send some ether(for locking) + fee (=1000 gwei * name's length) in this call.
     * If you try a fresh name, this simply registers your name and other information (explained in RegState struct).
     * If you try a existing name, this checks if you name has expired.
     * If so, there are two implementations.
     * If you are a previous owner of this name, this updates the RegState with a new lockTime and adding balance.
     * If you are not a previous owner of this name, this transfers the balance to the unlockedBalance and replaces with the sender's information.
     * 
     * Reminder. lock period has been set by 1 secons for testing and fee per one byte of name has been set by 1000 gwei, you can change this.
     */
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

    /**
     * @dev Increase currentTransaction so taht it makes the next registration available, especially call this when you get errors and reverted.
    */
    function allowNextTransaction() public {
        require(currentTransaction + 1 == transactionOrders[msg.sender], "Invalid ordered transaction");
        currentTransaction++;
    }

    /**
     * @dev You can withraw a locked balance of a name
     */
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

    /**
     * @dev If you are owner of this contract, you can withraw total fee.
     */
    function withrawFee() public payable onlyOwner {
        totalFeeBalance = 0;
        (bool withrawn, ) = msg.sender.call{value: totalFeeBalance}("");
        require(withrawn, "Transfer balance failed");
    }
}