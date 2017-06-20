pragma solidity ^0.4.11;

import "StandardToken.sol";
import "SafeMath.sol";

contract BNToken is StandardToken, SafeMath {

    string public name = 'Bitniex Token';
    string public symbol = 'BNT';
    string public version = 'V0.0.1';
    uint256 public decimals = 18;

    address public founder;
    uint256 public startBlock;
    uint256 public endBlock;

    bool public isFinalized;    // if the crowdsale is finished.
    uint256 public etherCap = 100000 * 10**decimals;
    uint256 public tokenCap = 200 * 10**6;
    
    event Allocation(address indexed investor, uint256 value);

    function BNToken(
        address _founder,
        uint256 _startBlock,
        uint256 _endBlock
    ) {
        if (_endBlock <= _startBlock) throw;

        founder = _founder;
        startBlock = _startBlock;
        endBlock = _endBlock;

        isFinalized = false;
    }

    function crowdsale() payable external {
        if (isFinalized) throw;
        if (block.number < startBlock || block.number > endBlock) throw;
        if (msg.value == 0) throw;

        uint256 tokens = safeMult(msg.value, rate());
        uint256 newSupply = safeAdd(totalSupply, tokens);
        if (tokenCap < newSupply) throw;
        
        totalSupply = newSupply;
        balances[msg.sender] += tokens;
        Allocation(msg.sender, tokens);
    }

    function rate() constant returns(uint256) {
        if (block.number < startBlock + 250) return 3000;    // early bird
        return 2000 + 800 * (endBlock - block.number) / (endBlock - startBlock + 1);
    }

}