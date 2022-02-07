# Solidity API

## RegisterName

_You can use this contract to register name with a certain balance and withraw unlocked fund after a certain period. This is implemented considering frontrunning._

### RegState

```solidity
struct RegState {
  address owner;
  uint256 transactionId;
  uint256 lockTime;
  uint256 balance;
}
```

### transactionCount

```solidity
uint256 transactionCount
```

The current transaction id

### currentTransaction

```solidity
uint256 currentTransaction
```

The current transaction id used when the registerName is called

### totalFeeBalance

```solidity
uint256 totalFeeBalance
```

The total fee

### transactionOrders

```solidity
mapping(address &#x3D;&gt; uint256) transactionOrders
```

The current transaction id of an account

### registeredStates

```solidity
mapping(bytes32 &#x3D;&gt; struct RegisterName.RegState) registeredStates
```

The registered status of the name

### unlockedBalances

```solidity
mapping(address &#x3D;&gt; uint256) unlockedBalances
```

The unlocked fund of an account

### constructor

```solidity
constructor() public
```

### Registered

```solidity
event Registered(string name, uint256 transactionId)
```

_Emitted when a new name is registered_

### newTransactionId

```solidity
function newTransactionId() public
```

_Generate new transaction id before registration. This must be called everytime when you are going to register name._

### getTransactionId

```solidity
function getTransactionId() public view returns (uint256)
```

_Get the current transaction id assigned to the sender._

### getRegState

```solidity
function getRegState(string name) public view returns (struct RegisterName.RegState)
```

_Get the registered information of name_

### getTotalFeeBalance

```solidity
function getTotalFeeBalance() public view returns (uint256)
```

_Get the total fee_

### getUnlockedBalance

```solidity
function getUnlockedBalance() public view returns (uint256)
```

_Get the unlocked fund of the sender_

### registerName

```solidity
function registerName(string name) public payable
```

_Register name with certain amount of fund to be locked for a certain period.
First fo all, you have to generate new transaction id by calling newTransactionId because avoid front-running attack.
You have to send some ether(for locking) + fee (&#x3D;1000 gwei * name&#x27;s length) in this call.
If you try a fresh name, this simply registers your name and other information (explained in RegState struct).
If you try a existing name, this checks if you name has expired.
If so, there are two implementations.
If you are a previous owner of this name, this updates the RegState with a new lockTime and adding balance.
If you are not a previous owner of this name, this transfers the balance to the unlockedBalance and replaces with the sender&#x27;s information.

Reminder. lock period has been set by 1 secons for testing and fee per one byte of name has been set by 1000 gwei, you can change this._

### withraw

```solidity
function withraw(string name) public payable
```

_You can withraw a locked balance of a name_

### withrawFee

```solidity
function withrawFee() public payable
```

_If you are owner of this contract, you can withraw total fee._

## RegisterName

### RegState

```solidity
struct RegState {
  address owner;
  uint256 transactionId;
  uint256 lockTime;
  uint256 balance;
}
```

### transactionCount

```solidity
uint256 transactionCount
```

### totalFeeBalance

```solidity
uint256 totalFeeBalance
```

### transactionOrders

```solidity
mapping(address &#x3D;&gt; uint256) transactionOrders
```

### registeredStates

```solidity
mapping(bytes32 &#x3D;&gt; struct RegisterName.RegState) registeredStates
```

### unlockedBalances

```solidity
mapping(address &#x3D;&gt; uint256) unlockedBalances
```

### constructor

```solidity
constructor() public
```

### Registered

```solidity
event Registered(bytes name, uint256 transactionId)
```

### getTransactionId

```solidity
function getTransactionId() public returns (uint256)
```

### registerName

```solidity
function registerName(bytes name, uint256 transactionId) public payable
```

### withraw

```solidity
function withraw(bytes name) public payable
```

### withrawFee

```solidity
function withrawFee() public payable
```

