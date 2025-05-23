# High

#### [H-1] `totalSupply` Not Updated in burn Function (Inconsistent Supply).

**Description:** Tokens are only getting burned from user's supply but still remain as it is in totalSupply

```solidity
  function burn(uint256 value) public {
        _balances[msg.sender] -= value;
        emit Transfer(msg.sender, address(0), value);
    }
```
**Impact:** The totalSupply() function will return an incorrect value that does not reflect the actual number of tokens in circulation. 

**Proof Of Code:**

```
function testApproveAndBurn() public {
    vm.prank(user);
    erc20BuggyImplementation8.burn(10 ether);
    assertEq(erc20BuggyImplementation8.totalSupply(),1000000 * 10 ** 18 );
}
```

**Mitigations:** Decrement `_totalSupply` by value in the burn function.

```solidity
function burn(uint256 value) public {
    // ... balance check ...
    _balances[msg.sender] -= value;
    _totalSupply -= value; // Added
    emit Transfer(msg.sender, address(0), value);
}
```



#### [H-2] Balance Check is missing in burn Function

**Description:** The `burn` function directly substracts value from _balances[msg.sender] without first checking if _balances[msg.sender] is greated than or equal to value that is being burned.


```solidity
  function burn(uint256 value) public {
        _balances[msg.sender] -= value;
        emit Transfer(msg.sender, address(0), value);
    }
```

**Impact:** If a user tries to burn more tokens than they possess, the subtraction will cause an underflow. In Solidity 0.8+, this will result in a panic(0x11) error, reverting the transaction. While the transaction reverts, it's a fundamental logic flaw and consumes gas unnecessarily. In older Solidity versions without checked arithmetic, this would lead to the user's balance wrapping around to an extremely large positive number, effectively creating tokens out of thin air.

**Proof Of Code:**

```solidity

function testBurningMoreThanAvialableTokens() public {
    vm.prank(makeAddr("tester"));
    vm.expectRevert();
    erc20BuggyImplementation8.burn(10 ether);
    assertEq(erc20BuggyImplementation8.totalSupply(),1000000 * 10 ** 18 );
    
}
```

**Mitigations:** Add a require statement to check for sufficient balance before subtraction.

```solidity
  function burn(uint256 value) public {
        require(_balances[msg.sender] >= value, "ERC20: burn amount exceeds balance"); // Added
        _balances[msg.sender] -= value;
        emit Transfer(msg.sender, address(0), value);
    }
```


# Informational

#### [I-1] Missing Approval Event Emission in `_approve` function.

**Description:** The `_approve` internal function sets the allowance but does not emit the Approval event. The approve public function calls _approve, so the event is never emitted when an approval is made.

**Impact:** Off-chain services (exchanges, wallets, block explorers, Dapps) rely heavily on events to track token approvals. Without this event, it's impossible for external systems to reliably know when an allowance has been set or changed. This breaks interoperability and can lead to users or contracts thinking an allowance is set when it isn't, or vice-versa, causing transaction failures or unexpected behavior in Dapps.

**Mitigations:** Add emit Approval(tokenOwner, spender, value); at the end of the _approve function.

```Solidity
function _approve(address tokenOwner, address spender, uint256 value) internal {
    // ... checks ...
    _allowances[tokenOwner][spender] = value;
+++++    emit Approval(tokenOwner, spender, value); // Added
}
```


