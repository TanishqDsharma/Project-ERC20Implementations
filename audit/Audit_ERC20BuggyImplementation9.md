# High

#### [H-1]: Missing Balance Check in transfer Function (Underflow Vulnerability).

**Description:** The transfer function directly subtracts amount from `_balances[msg.sender]` inside an unchecked block without a prior require check to ensure `msg.sender` has a sufficient balance.

**Impact:** . A user can call transfer with an amount larger than their balance. Because the operation is in an unchecked block, it will not revert with a panic. Instead, _balances[msg.sender] will underflow, wrapping around to an extremely large positive number, effectively creating an arbitrary amount of tokens for the sender. This leads to unlimited token inflation and destroys the token's value.

**Proof Of Code:**

```solidity

function testTransferMoreTokensThanAvialable() public {
    // Having zero tokens to transfer
    vm.startPrank(user2);
    erc20BuggyImplementation9.balanceOf(user2);
    vm.expectRevert();
    erc20BuggyImplementation9.transfer(user2, 100 ether);
    vm.stopPrank();
}

```

**Mitigation:** Add a require statement to check for sufficient balance before the unchecked subtraction.


```solidity
function transfer(address to, uint256 amount) public returns (bool) {
    require(_balances[msg.sender] >= amount, "ERC20: insufficient balance"); // ADDED
    unchecked {
        _balances[msg.sender] -= amount;
    }
    _balances[to] += amount;
    emit Transfer(msg.sender, to, amount);
    return true;
}
```


#### [H-2] Misisng balance check in `burn` function

**Description:** The _burn function directly subtracts amount from _balances[from] without a prior require check.

```solidity
  function _burn(address from, uint256 amount) internal virtual {
 @@@>         _balances[from] -= amount;

        unchecked {
          _totalSupply -= amount;
        }

        emit Transfer(from, address(0), amount);
    }
```

**Impact:** Similar to the transfer issue, if _burn were callable (e.g., via a public burn function without proper access control), a user could burn more tokens than they own, causing an underflow in their _balances and potentially creating tokens.


**Mitigation:** 

```solidity
function _burn(address from, uint256 amount) internal virtual {
++++    require(_balances[from] >= amount, "ERC20: burn amount exceeds balance"); // ADDED
    _balances[from] -= amount;
    unchecked {
        _totalSupply -= amount;
    }
    emit Transfer(from, address(0), amount);
}

```


# Low

#### [L-1] Missing Zero Address checks:

**Description:**

`transfer`Function : Missing checks for msg.sender != address(0) and to != address(0).
`approve` Function : Missing checks for msg.sender != address(0) and spender != address(0).
`_mint`   Function : Missing check for account != address(0).
`_burn`   Function : Missing check for from != address(0).

**Impact:** 

While transferring to address(0) often implies a burn (which is handled by emit Transfer(from, address(0), value)), explicitly preventing transfers to/from the zero address is an ERC-20 best practice for robustness and preventing unintended burns or approvals to/from a non-existent account.

**Mitigation:** 

<b>Add require(address != address(0), "Error Message"); checks in the respective functions.</b>

```Solidity

// In transfer:
require(msg.sender != address(0), "ERC20: transfer from the zero address");
require(to != address(0), "ERC20: transfer to the zero address");
```

```Solidity
// In approve:
require(msg.sender != address(0), "ERC20: approve from the zero address");
require(spender != address(0), "ERC20: approve to the zero address");
```


```Solidity
// In _mint:
require(account != address(0), "ERC20: mint to the zero address");
```

```Solidity
// In _burn:
require(from != address(0), "ERC20: burn from the zero address");

```
