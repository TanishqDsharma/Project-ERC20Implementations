# High 

#### [H-1] Incorrect Parameter Order in `transferFrom` Call to `_transfer` .

**Description:** Inside the `transferFrom` function, the internal`_transfer` function is called with `_transfer(to, from, value);`. This swaps the from and to addresses.

**Impact:** This is a major logical flaw that completely breaks the intended functionality of `transferFrom`. Instead of transferring tokens from the `from` address to the `to` address on behalf of the `msg.sender`, it will attempt to transfer tokens from the `to` address to the `from` address. 

**Proof Of Code:**

```solidity

    function testTransferFromUnIntenderTokenTransfer() public{
        vm.startPrank(user2);
        IERC20(address(erc20BuggyImplementation5)).approve(user, 10 ether);
        vm.stopPrank();
        
        vm.startPrank(user);
        IERC20(address(erc20BuggyImplementation5)).approve(user2, 5 ether);
        vm.stopPrank();

        vm.prank(user2);
        IERC20(address(erc20BuggyImplementation5)).transferFrom(user, user2, 5 ether);


        // Instead of transferring tokens to user2 transfer happened from user2 and user's balance got increased
        assertEq(IERC20(address(erc20BuggyImplementation5)).balanceOf(user),15 ether);
    }
```

**Mitigation:** Correct the order of parameters when calling _transfer inside transferFrom. It should be _transfer(from, to, value);.

```solidity
function transferFrom(address from, address to, uint256 value) public returns (bool) {
    _spendAllowance(from, msg.sender, value);
----    _transfer(to, from, value);
++++    _transfer(from, to, value); // Corrected: parameters are in the correct order
    return true;
}
```

### [H-2] Missing `burn` function

**Description:** The contract includes an internal `_mint` function (called in the constructor), but there is no corresponding `_burn` function, neither internal nor external.

**Impact:** There is no way to reduce the totalSupply of the token or to burn tokens from any account. This might be acceptable for a fixed-supply token that never burns, but if tokenomics rely on burning (e.g., for deflation or fee burning), this functionality is completely absent.

**Mitigation:** Implement a `_burn` internal function (similar to previous examples) and provide a public/external burn function with appropriate access control (e.g., onlyOwner for general burning, or allowing users to burn their own tokens).
