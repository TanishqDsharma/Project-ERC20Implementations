# High

#### [H-1] Access Control Mechanism is missing in `burn` Function

**Description:** Anyone can call burn function and burn tokens that belongs to other users

**Impact:** A malicious user could call burn to destroy tokens belonging to other users. This leads to a complete loss of funds for token holders whose addresses are targeted, severely compromising the token's integrity and value.

**Proof Of Code:**

```solidity
function testBurn() public{
        uint256 userInitialBalance = IERC20(address(erc20BuggyImplementation3)).balanceOf(user);

        vm.startPrank(user2);
        erc20BuggyImplementation3.burn(user,userInitialBalance);
        vm.stopPrank();

        uint256 userBalanceAfterBurn = IERC20(address(erc20BuggyImplementation3)).balanceOf(user);
        assert(userBalanceAfterBurn==0);
    }
```

**Mitigations:**

Refactor the below code to add a check like this: 

````solidity
  require(msg.sender == account, "Not authorized to burn");
````

# Low

#### [L-1] Incorrect Event Emission in burn()

**Description:** The `burn` function emits emit the below event: 

```solidity
 emit Transfer(address(0), account, amount);
```

The Transfer event for burning should indicate that tokens are transferred from the account to the zero address. 

**Impact:** 
The current emission suggests that tokens are being minted to the account from the zero address, which is misleading for off-chain tools and analytics.
