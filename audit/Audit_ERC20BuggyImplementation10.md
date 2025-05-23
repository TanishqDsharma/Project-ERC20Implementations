# High

#### [H-1] Incorrectly Implemented `onlyOwner` Modifer

**Description:** The onlyOwner modifier contains msg.sender == owner; followed by _;. The msg.sender == owner part is a boolean comparison, but its result is not used to enforce a condition or revert the transaction. The _; always executes, regardless of whether msg.sender is the owner.

```solidity
  modifier onlyOwner() {
        msg.sender == owner;
        _;
    }
```

**Impact:**  Functions protected by onlyOwner (e.g., mint, burn, transferOwnership, renounceOwnership) can be called by any address, not just the contract owner. This allows anyone to:

* Mint unlimited tokens to themselves or others.
* Burn any amount of tokens from any account (including other users').
* Change the contract owner or renounce ownership.


**Mitigation:** The onlyOwner modifier must use a require statement to enforce the condition.

```solidity

modifier onlyOwner() {
    require(msg.sender == owner, "Unauthorized"); // Correct implementation
    _;
}

```

