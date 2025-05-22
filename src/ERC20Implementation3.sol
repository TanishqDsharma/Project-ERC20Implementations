// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;


contract ERC20BuggyImplementation3{

    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Approval(address indexed owner, address indexed spender, uint256 amount);

    string public name;
    string public symbol;
    uint8 public decimals=18;
    uint256 private _totalSupply;

    mapping(address=>uint256) public _balances;
    mapping(address=>mapping(address=>uint256)) public _allowances;

    constructor(){
        name = "BuggyToken3";
        symbol = "BUG3";
        _mint(msg.sender, 1000000 * 10 ** 18);
    }

    function transfer(address to, uint256 amount) public returns(bool){
        _transfer(msg.sender,to,amount);
        return true;
    }
    
    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) public returns (bool) {
        _spendAllowance(from, msg.sender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function _transfer(address from, address to, uint256 amount) internal{
        require(to != address(0), "Invalid receiver");
        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "Insufficient balance");

        _balances[from] = fromBalance - amount;
        _balances[to] += amount;
        emit Transfer(from, to, amount);
    }

    function _approve(address owner,address spender, uint256 amount) internal{
        require(owner!=address(0),"Zero Address");
        require(spender!=address(0),"Zero Address");
         _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

     function _spendAllowance(address tokenOwner, address spender, uint256 value) internal {
        uint256 currentAllowance = allowance(tokenOwner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= value, "Challenge3: insufficient allowance");
            _allowances[tokenOwner][spender] = currentAllowance - value;
        }
    }

    function _mint(address account, uint256 amount) internal virtual{
        _totalSupply+=amount;
        _balances[account]+=amount;
        emit Transfer(address(0),account,amount);
    }

  
    function burn(address account, uint256 amount) public{
        require(account!=address(0),"Zero Address");
        uint256 accountBalance = _balances[account];
        require(accountBalance>=amount,"Insufficient balance");
        _totalSupply-=amount;
        _balances[account]=accountBalance-amount;
        emit Transfer(address(0),account,amount);
    }
}
