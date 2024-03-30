// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract SchizoToken is ERC20, Ownable {
    constructor(string memory _name, string memory _symbol, uint8 _decimals, uint256 _totalSupply) ERC20(_name, _symbol) {
        decimals = _decimals;
        _mint(msg.sender, _totalSupply);
    }

    function approve(address _spender, uint256 _value) public override  returns (bool) {
        super.approve(_spender, _value);
        emit Approval(owner(), _spender, _value);
        return true;
    }

    function transfer(address _to, uint256 _value) public override returns (bool) {
        super.transfer(_to, _value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public override returns (bool) {
        super.transferFrom(_from, _to, _value);
        emit Transfer(_from, _to, _value);
        return true;
    }
}
