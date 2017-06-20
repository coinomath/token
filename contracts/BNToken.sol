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
    uint256 public etherMin = 50000 * 10**decimals;     // the minest ether for crowdsale
    uint256 public tokenCap = 2 * (10**8) * 10**decimals;
    uint256 public totalInvestment;
    mapping (address => uint256) investments;
    
    event Invest(address indexed investor, uint256 value);
    event Allocation(address indexed investor, uint256 value);
    event Refund(address indexed investor, uint256 value);

    function BNToken(
        address _founder,
        uint256 _startBlock
    ) {
        founder = _founder;
        startBlock = _startBlock;
        endBlock = startBlock + 4 * 7 * 60000; // 4 weeks

        isFinalized = false;    // default to false
        totalSupply = 15 * (10**6) * 10**decimals;
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
        
        investments[msg.sender] = msg.value;
        totalInvestment = safeAdd(totalInvestment, msg.value);
        Invest(msg.sender, msg.value);

        totalSupply = newSupply;
        balances[msg.sender] += tokens;
        Allocation(msg.sender, tokens);
    }

    /**
     * rate
     * get rate on realtime
     */
    function rate() constant returns(uint256) {
        if (block.number < startBlock + 250) return 3300;       // early bird
        if (block.number < startBlock + 420000) return 3000;    // price of first week
        if (block.number < startBlock + 840000) return 2750;    // price of second week
        if (block.number < startBlock + 1260000) return 2500;   // price of third week
        if (block.number <= endBlock) return 2250;              // price of last(fourth) week
        throw;
    }

    /**
     * finish the crowdsale
     */
    function finalized() external {
        if (isFinalized) throw;
        if (msg.sender != founder) throw;
        if (totalInvestment < etherMin) throw;
        if (block.number <= endBlock) throw;
        isFinalized = true;
        if (!founder.send(this.balance)) throw;
    }

    /**
     * refund
     * use for refunding on crowdsale faild
     */
    function refund() external {
        if (isFinalized) throw;
        if (block.number <= endBlock) throw;
        if (totalInvestment >= etherMin) throw;
        if (msg.sender == founder) throw;

        uint value = invests[msg.sender];
        if (value <= 0) throw;
        totalInvestment = safeSubtract(totalInvestment, value);
        totalSupply = safeSubtract(totalSupply, balances[msg.sender]);
        investments[msg.sender] = 0;
        balances[msg.sender] = 0;

        // send assets
        // notice that if you're using a contract; make sure it works with .send gas limits
        if (!msg.sender.send(value)) throw;
        Refund(msg.sender, value); 
    }
}