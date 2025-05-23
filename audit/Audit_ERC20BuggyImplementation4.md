# High

### [H-1] Mising protocol paused check in `ERC20BuggyImplementation4::transferFrom` function

**Description:** The `transfer` function correctly includes require(!paused, "Challenge4: transfers paused");, but the `transferFrom` function (which is also a token transfer mechanism) does not have this check.

```solidity
        require(!paused, "Challenge4: transfers paused");
```

So, the tokens are transferred even if the protocol is not working .

**Impact:** This is a severe security flaw. If the contract is paused, users can still bypass the pause by using the transferFrom function. This defeats the entire purpose of pausing transfers, allowing malicious activity or exploitation to continue even when the contract is supposedly halted.

**Proof Of Code:**

```solidity
function testTransferIfProtocolIsPaused() public{
        vm.startPrank(user);
        IERC20(address(erc20BuggyImplementation4)).transfer(user2,5 ether);
        vm.stopPrank();

        vm.startPrank(erc20BuggyImplementation4.owner());
        erc20BuggyImplementation4.pause();
        vm.stopPrank();

        assertEq(erc20BuggyImplementation4.paused(),true);


        vm.startPrank(user2);
        IERC20(address(erc20BuggyImplementation4)).approve(user2,2 ether);
        IERC20(address(erc20BuggyImplementation4)).transferFrom(user2,user,1 ether);
        vm.stopPrank();

        uint256 userBalanceAfterTransferFrom =  IERC20(address(erc20BuggyImplementation4)).balanceOf(user);
        assertEq(userBalanceAfterTransferFrom,6 ether);
        

    }
```

**Mitigation:** 

Add the below check in `transferFrom` function:

```solidity
        require(!paused, "Challenge4: transfers paused");
```

### [H-2] Missing `burn` function

**Description:** The contract includes an internal `_mint` function (called in the constructor), but there is no corresponding `_burn` function, neither internal nor external.

**Impact:** There is no way to reduce the totalSupply of the token or to burn tokens from any account. This might be acceptable for a fixed-supply token that never burns, but if tokenomics rely on burning (e.g., for deflation or fee burning), this functionality is completely absent.

**Mitigation:** Implement a `_burn` internal function (similar to previous examples) and provide a public/external burn function with appropriate access control (e.g., onlyOwner for general burning, or allowing users to burn their own tokens).

# Informational

### [I-1] Mising Zero Address

**Description:** Mising Zero Address Check in `_transfer` function for `From` address

```solidity
function _transfer(address from, address to, uint256 value) internal {
        require(to != address(0), "Challenge4: transfer to zero address");

        uint256 fromBalance = _balances[from];
        require(fromBalance >= value, "Challenge4: insufficient balance");

        _balances[from] = fromBalance - value;
        _balances[to] += value;
        emit Transfer(from, to, value);
    }

```

**Mitigations:**

Add the below check in the code:

```solidity
function _transfer(address from, address to, uint256 value) internal {
       require(to != address(0), "Challenge4: transfer to zero address");
++++   require(from != address(0), "Challenge4: transfer from zero address");
        uint256 fromBalance = _balances[from];
        require(fromBalance >= value, "Challenge4: insufficient balance");

        _balances[from] = fromBalance - value;
        _balances[to] += value;
        emit Transfer(from, to, value);
    }

```
