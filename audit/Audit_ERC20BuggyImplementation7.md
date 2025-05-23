# High


#### [H-1] Missing Access Control on `mint` function

**Description:** Anyone in the contract can call the `mint` function and mint tokens to them or to other users.

```solidity
 function mint(address to, uint256 value) public {
        _mint(to, value);
    }

```

**Impact:** Any user can mint an arbitrary amount of new tokens to any address, including their own.

**Proof Of Code:**

```solidity

function testAnyoneCanMint() public{
        uint256 initialBalance = IERC20(address(erc20BuggyImplementation7)).balanceOf(user);
        vm.startPrank(user);
        erc20BuggyImplementation7.mint(user,10000000 ether);
        vm.stopPrank();
        uint256 balanceAfterMint = IERC20(address(erc20BuggyImplementation7)).balanceOf(user);
        assert(balanceAfterMint>initialBalance);
}
```

**Mitigation:** 

Add access control to the mint function or create an `onlyOwner` modifier and apply it to the function



```solidity
----- function mint(address to, uint256 value) public {
+++++ function mint(address to, uint256 value) public onlyOwner {
        _mint(to, value);
    }

```



#### [H-2] Missing `burn` function

**Description:** The contract includes an internal `_mint` function (called in the constructor), but there is no corresponding `_burn` function, neither internal nor external.

**Impact:** There is no way to reduce the totalSupply of the token or to burn tokens from any account. This might be acceptable for a fixed-supply token that never burns, but if tokenomics rely on burning (e.g., for deflation or fee burning), this functionality is completely absent.

**Mitigation:** Implement a `_burn` internal function (similar to previous examples) and provide a public/external burn function with appropriate access control (e.g., onlyOwner for general burning, or allowing users to burn their own tokens).
