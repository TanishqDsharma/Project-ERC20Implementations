# High

#### [H-1] In contract `ERC20BuggyImplementation2::approve()` is not implemented as described in ERC20 standard

**Description:** The approve() function allows anyone to set the allowance for any pair of owner and spender by calling:

```solidity

@@@>    function approve(address owner, address spender, uint256 amount) public {
        allowance[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

```
This is not compliant with ERC20 behavior, where only the token owner should be able to approve a spender.

**Impact:**  Attacker can pass any owner address and gives his address maxium approval of tokens that belongs to owner and later transfer it to his address.

**Proof Of Code:**

* Attacker calls approve(victim, attacker, MAX_UINT256)
* Attacker calls transferFrom(victim, attacker, X)
* Tokens are stolen.

**Mitigations:**

The above approve function can be refactored as:

```solidity
function approve(address spender, uint256 amount) public virtual returns (bool) {
    allowance[msg.sender][spender] = amount;
    emit Approval(msg.sender, spender, amount);
    return true;
}
```

#### [H-2] In contract `ERC20BuggyImplementation2::transfer` amount is deducted before balance check:

**Description:** Balance is not checked before deducting it from the final supply. In `transfer`, `transferFrom`, and `_burn`, balances are reduced without checking if the user has sufficient balance. 

```solidity
  balanceOf[msg.sender] -= amount; // transfer
  balanceOf[from] -= amount;       // transferFrom and _burn
```

**Impact:** 

Although Solidity 0.8+ automatically reverts on underflows, this still leads to:

* Uninformative error messages
* Denial of service
* Unexpected behavior if used in try/catch or delegated calls


**Mitigation:**

Add the below check:

```solidity
require(balanceOf[msg.sender] >= amount, "ERC20: insufficient balance");
```

#### [H-3] Missing allowance check in contract `ERC20BuggyImplementation2::transferFrom` function

**Description:** If the approvedAmount is less than the token being transfered the function reverts

```solidity
function transferFrom(address from, address to, uint256 amount) public virtual returns(bool){
        uint256 allowed = allowance[from][msg.sender];
        if(allowed != type(uint256).max){
 @@@@>           allowance[from][msg.sender] = allowed - amount;
        }
        balanceOf[from] -= amount;
        
        unchecked {
            balanceOf[to] += amount;
        }

        emit Transfer(from, to, amount);

        return true;
    }
```

**Impact:** The transfer of token will fail lead to denial of service.

**Mitigations:**

Add the below check in the code:

```solidity
require(allowed >= amount, "ERC20: insufficient allowance");
```

# Low

### [L-1] No return values for approve()

**Description:** No return values are implemented in the approve() function which is required according to the ERC20 standard.

**Impact:** This can cause compatibility issues with dApps and interfaces expecting this return value.

**Mitigations:**

Refactor the code as below:

```solidity
function approve(address owner, address spender, uint256 amount) public returns(bool) {
        allowance[owner][spender] = amount;
        emit Approval(owner, spender, amount);
+++++   return true;
    }
```
