# High

#### [H-1] _transfer functions missing the substraction of the amount from sender's balance

**Description:** The `_transfer` function inside the contract adds amount to the reciver so the balance is updated but forgets to substract the amount from the sender's balance.

```solidity

        // It retrieves the balance of the from address.
@>        uint256 fromBalance = _balances[from];
```
**Impact:** This means that when transfer or transferFrom is called, tokens are created out of thin air. The sender keeps their tokens, and the receiver gets new ones. 
This leads to unlimited token inflation and a complete breakdown of the token's economic model.

**Mitigation:** Add mechanism to substract the amount of tokens from the `from` address as well

```solidity
// It retrieves the balance of the from address.
--        uint256 fromBalance = _balances[from];
++        uint256 fromBalance = _balances[from] - value ;
```

#### [H-2] totalSupply always remains zero

**Description:** The totalSupply is not initialzed in constructor and _mint function inside the contract is not being called in any function and _mint function is not directly callable as its visiblity is internal

```solidity
constructor(string memory name_, string memory symbol_) {
        _name=name_;
        _symbol=symbol_;
    }
```

**Impact:** On deployment, _totalSupply will be 0, and _balances for all addresses will be 0. The token will be non-functional as no tokens exist to be transferred.

**Mitigation:** Initialize the totalSupply in constructor or call _mint inside constructor to mint some supply of the tokens.
