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
    uint256 public etherCap = 100000 * 10**decimals;    // the most ether for crowdsale
    uint256 public tokenCap = 2 * 10**8;
    
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

        isFinalized = false;    // default to false
        totalSupply = 15 * 10**6;
        balances[founder] = totalSupply;
        Allocation(founder, totalSupply);
    }

    /**
     * crowdsale
     */
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

    /**
     * rate
     * get rate on realtime
     */
    function rate() constant returns(uint256) {
        if (block.number < startBlock + 250) return 3300;    // early bird
        if (block.number < startBlock + 420000) return 3000;
        if (block.number < startBlock + 840000) return 2750;
        if (block.number < startBlock + 1260000) return 2500;
        if (block.number <= endBlock) return 2250; 
        throw;
    }

}