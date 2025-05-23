# High

#### [H-1] Incomplete Blacklist Implementation in `transferFrom` and `approve`.

**Description:** 

The `transfer` function correctly checks:

```soildity
!blacklist[msg.sender] && !blacklist[to]
```
However, `transferFrom` only checks for `to` address but fails to check if the from address (the actual token owner) is blacklisted. 

```solidity
!blacklist[msg.sender] && !blacklist[to]
```

Similarly, the approve function has no blacklist checks at all.

**Impact:** This severely undermines the blacklist's effectiveness. A blacklisted user (as from in transferFrom) could still have their tokens transferred by an approved non-blacklisted spender, or even by themselves if they approve a non-blacklisted address they control. A blacklisted user could still approve a spender, and a non-blacklisted spender could still approve a blacklisted user. This allows a blacklisted address to continue participating in the allowance mechanism.


**Proof Of Code**

```
function testApproveAndThenTransfer() public{
        vm.prank(owner);
        erc20BuggyImplementation6.addToBlacklist(user2);
        
        vm.startPrank(user2);
        erc20BuggyImplementation6.approve(maliciousAddress,10 ether);
        vm.stopPrank();

        vm.startPrank(maliciousAddress);
        erc20BuggyImplementation6.transferFrom(user2,maliciousAddress, 9 ether);
        vm.stopPrank();

    }
```

The test successfully demonstrates that:

* A blacklisted account (user2) can still approve a spender.
* A non-blacklisted spender (maliciousAddress) can then transferFrom tokens from the blacklisted account (user2), even though user2 is blacklisted.

This proves that the blacklist implementation is ineffective at preventing blacklisted accounts from having their tokens moved through the allowance mechanism

**Mitigation:**

For transferFrom:  Add a blacklist check for the from address.

```solidity
function transferFrom(address from, address to, uint256 value) public returns (bool) {
    // All parties involved in the transfer (from, to, and msg.sender) should not be blacklisted.
    require(!blacklist[from] && !blacklist[to] && !blacklist[msg.sender], "Challenge06: Blacklisted address involved");
    _spendAllowance(from, msg.sender, value);
    _transfer(from, to, value);
    return true;
}
```

For approve: Add blacklist checks for both the owner (msg.sender) and the spender.

```solidity
function approve(address spender, uint256 value) public returns (bool) {
    // Both approver and approved spender should not be blacklisted.
    require(!blacklist[msg.sender] && !blacklist[spender], "Challenge06: Blacklisted address involved in approval");
    _approve(msg.sender, spender, value);
    return true;
}
```

### [H-2] Missing `burn` function

**Description:** The contract includes an internal `_mint` function (called in the constructor), but there is no corresponding `_burn` function, neither internal nor external.

**Impact:** There is no way to reduce the totalSupply of the token or to burn tokens from any account. This might be acceptable for a fixed-supply token that never burns, but if tokenomics rely on burning (e.g., for deflation or fee burning), this functionality is completely absent.

**Mitigation:** Implement a `_burn` internal function (similar to previous examples) and provide a public/external burn function with appropriate access control (e.g., onlyOwner for general burning, or allowing users to burn their own tokens).
