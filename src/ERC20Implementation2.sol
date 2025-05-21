// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;


contract ERC20BuggyImplementation2 {
    
    event Transfer(
        address indexed from,
        address indexed to,
        uint256 amount);
    
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 amount
    );

    string public name;
    string public symbol;
    uint8 public immutable decimals;
    uint256 public totalSupply;
    
    /**
     * @notice This mapping tracks balance of a specific address
     */
    mapping(address=>uint256) public balanceOf;
    
    /**
     * @notice This mapping tracks number of tokens allowed to spend by spender on behalf of owner
     */
    mapping(address=>mapping(address=>uint256)) public allowance;

 
    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals){
        name=_name;
        symbol=_symbol;
        decimals=_decimals;
    }

    /**
     * @notice This functions allows the owner to set a spender who can spend tokens on behalf of user.
     * @param owner Address of the user who owns the token
     * @param spender Address of the recipient who can spend tokens on behalf of owner
     * @param amount Amount of tokens
     */

   

    function approve(address owner, address spender, uint256 amount) public {
        allowance[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @notice This function allows the user to transfer tokens
     * @param to Address of the recipient
     * @param amount Amount of tokens to Transfer
     */

    
    function transfer(address to, uint256 amount) public virtual returns (bool){
        balanceOf[msg.sender] -= amount;
         unchecked {
            balanceOf[to] += amount;
        }
        emit Transfer(msg.sender, to, amount);
        return true;
    }

    
    function transferFrom(address from, address to, uint256 amount) public virtual returns(bool){
        uint256 allowed = allowance[from][msg.sender];
        if(allowed != type(uint256).max){
            allowance[from][msg.sender] = allowed - amount;
        }
        balanceOf[from] -= amount;
        
        unchecked {
            balanceOf[to] += amount;
        }

        emit Transfer(from, to, amount);

        return true;
    }

    
    function _mint(address to, uint256 amount) internal virtual{
        totalSupply+=amount;
        unchecked{
              balanceOf[to] += amount;
        }
        emit Transfer(address(0), to, amount);
    }

    function _burn(address from, uint256 amount) internal virtual{
        balanceOf[from] -= amount;
        unchecked{
           totalSupply-=amount;
        }
        emit Transfer(from, address(0),amount);
    }
}
