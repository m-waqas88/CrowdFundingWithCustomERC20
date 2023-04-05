// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ERC20 {
    error InvalidAmount();
    error InvalidAddress();
    error notOwner();
    modifier CheckAmount(uint amount) {
        if (amount < 1) {
            revert InvalidAmount();
        }
        _;
    }
    modifier CheckAddress(address recipient) {
        if (recipient == address(0)) {
            revert InvalidAddress();
        }
        _;
    }
    modifier onlyOwner()
    {
      if(msg.sender != owner){
        revert notOwner();
      }
      _;
    }
    modifier Reentrant()
    {
      if(!executing) {
        executing = true;
        _;
      }
      executing = false;
    }
    bool private executing;
    address public owner;
    uint public totalSupply;
    mapping(address => uint) public balanceOf;
    string public name;
    string public symbol;
    uint8 public decimals;

    event Transfer(address indexed from, address indexed to, uint value);

    constructor(uint amount) {
        owner = msg.sender;
        name = "Metacrafter Tokens";
        symbol = "MCT";
        decimals = 18;
        mint(amount);
    }

    function mint(uint amount) public Reentrant {
        balanceOf[msg.sender] += amount;
        totalSupply += amount;
        emit Transfer(address(0), msg.sender, amount);
    }

    function burn(uint amount) external onlyOwner Reentrant {
        balanceOf[msg.sender] -= amount;
        totalSupply -= amount;
        emit Transfer(msg.sender, address(0), amount);
    }

    function _transferTokens(
        address _poolingContract,
        address _to,
        uint _amount
    ) internal {
        balanceOf[_poolingContract] -= _amount;
        balanceOf[_to] += _amount;
        emit Transfer(_poolingContract, _to, _amount);
    }

    function transfer(
        address recipient,
        uint amount
    ) public Reentrant CheckAmount(amount) CheckAddress(recipient) {
        balanceOf[msg.sender] -= amount;
        balanceOf[recipient] += amount;
        emit Transfer(msg.sender, recipient, amount);
    }

}