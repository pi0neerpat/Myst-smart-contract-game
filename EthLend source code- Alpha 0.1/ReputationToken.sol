pragma solidity ^0.4.11;

// Standard token interface (ERC 20)
// https://github.com/ethereum/EIPs/issues/20
contract Token 
{
// Functions:

    function totalSupply() constant returns (uint256) {}

    function balanceOf(address) constant returns (uint256) {}

    function transfer(address, uint256) returns (bool) {}

    function transferFrom(address, address, uint256) returns (bool) {}

    function approve(address, uint256) returns (bool) {}

    function allowance(address, address) constant returns (uint256) {}

// Events:
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

contract StdToken is Token // Transfer functions deleted!
{
// Fields:
     mapping(address => uint256) balances;
     mapping (address => mapping (address => uint256)) allowed;

     uint256 public allSupply = 0;

// Functions:
     function transfer(address _to, uint256 _value) returns (bool success) 
     {
          if((balances[msg.sender] >= _value) && (balances[_to] + _value > balances[_to])) 
          {
               balances[msg.sender] -= _value;
               balances[_to] += _value;

               Transfer(msg.sender, _to, _value);
               return true;
          } 
          else 
          { 
               return false; 
          }
     }

     function transferFrom(address _from, address _to, uint256 _value) returns (bool success) 
     {
          if((balances[_from] >= _value) && (allowed[_from][msg.sender] >= _value) && (balances[_to] + _value > balances[_to])) 
          {
               balances[_to] += _value;
               balances[_from] -= _value;
               allowed[_from][msg.sender] -= _value;

               Transfer(_from, _to, _value);
               return true;
          } 
          else 
          { 
               return false; 
          }
     }

     function balanceOf(address _owner) constant returns (uint256) 
     {
          return balances[_owner];
     }

     function approve(address _spender, uint256 _value) returns (bool success) 
     {
          allowed[msg.sender][_spender] = _value;
          Approval(msg.sender, _spender, _value);

          return true;
     }

     function allowance(address _owner, address _spender) constant returns (uint256 remaining) 
     {
          return allowed[_owner][_spender];
     }

     function totalSupply() constant returns (uint256 supplyOut) 
     {
          supplyOut = allSupply;
          return;
     }
}

contract ReputationToken is StdToken {
     string public name = "EthlendReputationToken";
     uint public decimals = 18;
     string public symbol = "CRE";

     address public creator = 0x0;
     address public ledger = 0x0;
     mapping(address => uint256) balancesLocked;

     function ReputationToken(){
          creator = msg.sender;
          ledger = msg.sender;
     }

     function lockedOf(address _owner) constant returns (uint256) 
     {
          return balancesLocked[_owner];
     }
     

     function changeCreator(address newCreator){
          if(msg.sender!=creator)throw;

          creator = newCreator;
     }

     function changeLedger(address newLedger){
          if(msg.sender!=creator)throw;

          ledger = newLedger;
     }

     function issueTokens(address forAddress, uint tokenCount) returns (bool success){
          if(msg.sender!=ledger)throw;
          
          if(tokenCount==0) {
               success = false;
               return ;
          }

          balances[forAddress]+=tokenCount;
          allSupply+=tokenCount;

          success = true;
          return;
     }

     function burnTokens(address forAddress) returns (bool success){
          if(msg.sender!=ledger)throw;

          allSupply-=balances[forAddress];

          balances[forAddress]=0;
          success = true;
          return;
     }

     function lockTokens(address forAddress, uint tokenCount) returns (bool success){
          if(msg.sender!=ledger) throw;
          if(balances[forAddress]-balancesLocked[forAddress]<tokenCount) throw;
          balancesLocked[forAddress]+=tokenCount;
          success = true;
          return;
     }

     function unlockTokens(address forAddress, uint tokenCount) returns (bool success){
          if(msg.sender!=ledger) throw;
          if(balancesLocked[forAddress]<tokenCount) throw;
          balancesLocked[forAddress]-=tokenCount;
          success = true;
          return;
     }

     function nonLockedTokensCount(address forAddress) constant returns (uint tokenCount){
          if ( balancesLocked[forAddress] > balances[forAddress] ){
               tokenCount = 0;
               return;
          } else {
               tokenCount = balances[forAddress] - balancesLocked[forAddress];
               return;
          }

     }

     function transferFrom(address, address, uint256) returns (bool success){
          success = false;
          return;
     }

     function transfer(address, uint256) returns (bool success){
          success = false;
          return;      
     }
}
