// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.20;


import "../lib/forge-std/src/Test.sol";
import {ERC20BuggyImplementation1} from "../src/ERC20Implementation1.sol";


contract TestERC20Implementation1 is Test {

ERC20BuggyImplementation1 erc20Implementation1;
address user = makeAddr("user");

    function setUp() external{
        erc20Implementation1 = new ERC20BuggyImplementation1("Buggy","BUGGY20");
    }

    function testGetTokenName() public {
        assertEq(erc20Implementation1.name(),"Buggy");
    }

    function testGetTokenSymbol() public {
        assertEq(erc20Implementation1.symbol(),"BUGGY20");
    }

    function testGetTokenDecimals() public{
        assertEq(erc20Implementation1.decimals(),18);
    }

    // This test confirm that totalSupply will always be zero as its not initialzed in the constructor.
    function testTotalSupply() public{
        assertEq(erc20Implementation1.totalSupply(),0);
    }

    function testGetTokenBalance() public{
        assertEq(erc20Implementation1.balanceOf(address(user)),0);
    }

    
}
