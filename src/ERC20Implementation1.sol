// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;


contract ERC20BuggyImplementation1 {
    
    string private _name;
    string private _symbol;
    uint8 private constant ERC20DECIMALS = 18;
    
    event Transfer(address indexed from,
                   address indexed to,
                   uint256 value);

    event Approval(address indexed owner,
                    address indexed spender,
                    uint256 value);

    /**
     * @dev This mapping is used to store the balance of each address that 
     * holds the token.
     */
    mapping(address=>uint256) private _balances;

    /**
     * @dev This nested mapping implements the ERC-20 allowance mechanism.
     * It allows the token holders to authorize specific address example dex's contracts
     * to spend a certain amount of their tokens without giving them full control 
     * over their entire balance
     */
    mapping(address=>mapping(address=>uint256)) private _allowances;

    //**************//
    //*** ERRORS ***//
    //**************//

    error InsufficientBalance(address sender, uint256 balance, uint256 needed);
    error InvalidSender(address sender);
    error InvalidReceiver(address receiver);
    error InsufficientAllowance(address spender, uint256 allowance, uint256 needed);
    error InvalidApprover(address approver);
    error InvalidSpender(address spender);
    uint256 private _totalSupply;

    constructor(string memory name_, string memory symbol_) {
        _name=name_;
        _symbol=symbol_;
    }

    /**
     * @notice allows to read name of the token
     */
    function name() public view virtual returns(string memory){
        return _name;
    }

    /**
     * @notice allows to read symbol of the token
     */
    function symbol() public view virtual returns(string memory){
        return _symbol;
    }

    /**
     * @notice allows to read decimals of the token
     */

    function decimals() public view virtual returns(uint256){
        return ERC20DECIMALS;
    }

    /**
     * @notice allows to read totalSupply of the token
     */
    function totalSupply() public view virtual returns(uint256){
        return _totalSupply;
    }

    /**
     * @notice allows to read balance from a specific address
     */
    function balanceOf(address user) public view returns(uint256){
        return _balances[user];
    }

    /**
     * @dev allows to transfer tokens to a specified address
     * @param to Address of the recipient
     * @param value  Amount of tokens to transfer
     * 
     */

    function transfer(address to, uint256 value) public  virtual returns(bool){
        address owner = msg.sender;
        _transfer(owner,to,value);
        return true;
    }

    /**
     * @notice his function allows anyone to query the current allowance granted by a token owner to a specific spender. 
     * It retrieves the allowance value from the _allowances nested mapping.
     * 
     * @param owner Address of the owner 
     * @param spender Address of the user who spend the tokens on behalf of the owner
     */
    function allowance(address owner, address spender) public view virtual returns(uint256){
        return _allowances[owner][spender];
    }

    /**
     * @notice This function allows the caller (msg.sender, the token owner) to approve a spender address to spend up to a certain value of their token
     * @param spender Address authorized to spend
     * @param value Allowed Amount to spend
     */

    function approve(address spender, uint256 value) public  virtual returns(bool){
        address owner = msg.sender;
        _approve(owner, spender, value);
        return true;
    }

    /**
     * @notice This function allows an approved spender to transfer tokens from the from address to the to address, up to the allowance granted by the from address. 
     * It first calls _spendAllowance to decrease the spender's allowance and then calls the internal _transfer function to execute the token transfer.
     * @param from Address of the Sender
     * @param to Address of the Recipient
     * @param value Amount of tokens to transfer
     */
    function transferFrom(address from, address to, uint256 value) public virtual returns(bool){
        address spender = msg.sender;
        _spendAllowance(from, spender, value);
        _transfer(from, to, value);
        return true;
    }

    /**
     * 
     * @param from Address of the Sender
     * @param to Address of the Recipient
     * @param value Amount of Tokens to Transfer
     */

    function _transfer(address from, address to, uint256 value) internal{

        // reverts if the ``from`` address is the zero address
        if(from == address(0)) revert InvalidSender(from);
        // reverts if the ``to`` address is the zero address
        if(to == address(0)) revert InvalidReceiver(to);

        // It retrieves the balance of the from address.
        uint256 fromBalance = _balances[from];

        // It reverts if the from address has insufficient balance to transfer the value
        if(fromBalance<value) revert InsufficientBalance(from, fromBalance, value);
        
        // If all checks pass, it decreases the balance of the from address, increases the balance of the to address, and emits the Transfer event.
        // @audit substraction from the from address is missing
        _balances[to]+=value;
        emit Transfer(from, to, value);
    }

    function _approve(address owner, address spender, uint256 value) internal {
        // reverts if the address of the owner is zero
        if (owner == address(0)) revert InvalidApprover(owner);
        // reverts if the address of the spender is zero
        if (spender == address(0)) revert InvalidSpender(spender);

        // Updated the allowances mapping 
        _allowances[owner][spender] = value;
        emit Approval(owner, spender, value);
    }


    function _spendAllowance(address owner, address spender, uint256 value) internal{
        // first retrieves the current allowance. 
        uint256 currentAllowance = allowance(owner, spender);
        // If the allowance is not the maximum value (type(uint256).max, often used for infinite approval), it checks if the 
        // current allowance is sufficient for the value being spent.
        if(currentAllowance!=type(uint256).max){
            if(currentAllowance<value) revert InsufficientAllowance(spender, currentAllowance, value);

            // The unchecked block is used for the subtraction, which can save a small amount of gas by skipping overflow checks 
            unchecked {
                _approve(owner, spender, currentAllowance - value);
            }
        }
    }

  
    function _mint(address account, uint256 value) internal{
        // Reverts if the address of the account is zero
        if(account == address(0)) revert InvalidReceiver(account);
        // Minted tokens added to the totalSupply
        _totalSupply+=value;
        // Adding minted tokens to user's account
        _balances[account]+=value;
        emit Transfer(address(0), account, value);
    }

      
    function _burn(address account, uint256 value) internal{
        if(account==address(0)) revert InvalidSender(account);
        uint256 accountBalance = _balances[account];
        if (accountBalance < value) revert InsufficientBalance(account, accountBalance, value);
        _balances[account] = accountBalance -value;
        _totalSupply-=value;
        emit Transfer(account, address(0), value);
    }



}

