pragma solidity ^0.4.11;

contract SafeMath {
     function safeMul(uint a, uint b) internal returns (uint) {
          uint c = a * b;
          assert(a == 0 || c / a == b);
          return c;
     }

     function safeSub(uint a, uint b) internal returns (uint) {
          assert(b <= a);
          return a - b;
     }

     function safeAdd(uint a, uint b) internal returns (uint) {
          uint c = a + b;
          assert(c>=a && c>=b);
          return c;
     }

     function assert(bool assertion) internal {
          if (!assertion) throw;
     }
}

contract ERC20Token {
     function balanceOf(address _address) constant returns (uint balance);
     function transfer(address _to, uint _value) returns (bool success);
}

contract ReputationTokenInterface {
     function issueTokens(address forAddress, uint tokenCount) returns (bool success);
     function burnTokens(address forAddress) returns (bool success);
     function lockTokens(address forAddress, uint tokenCount) returns (bool success);
     function unlockTokens(address forAddress, uint tokenCount) returns (bool success);
     function approve(address _spender, uint256 _value) returns (bool success);
     function nonLockedTokensCount(address forAddress) constant returns (uint tokenCount);
}

contract AbstractENS {
     function owner(bytes32 node) constant returns(address);
     function resolver(bytes32 node) constant returns(address);
     function ttl(bytes32 node) constant returns(uint64);
     function setOwner(bytes32 node, address owner);
     function setSubnodeOwner(bytes32 node, bytes32 label, address owner);
     function setResolver(bytes32 node, address resolver);
     function setTTL(bytes32 node, uint64 ttl);

     // Logged when the owner of a node assigns a new owner to a subnode.
     event NewOwner(bytes32 indexed node, bytes32 indexed label, address owner);

     // Logged when the owner of a node transfers ownership to a new account.
     event Transfer(bytes32 indexed node, address owner);

     // Logged when the resolver for a node changes.
     event NewResolver(bytes32 indexed node, address resolver);

     // Logged when the TTL of a node changes
     event NewTTL(bytes32 indexed node, uint64 ttl);
}

contract Registrar {

     function transfer(bytes32, address){
          return;
     } 

}


contract Ledger is SafeMath {
     // who deployed Ledger
     address public mainAddress;
     address public whereToSendFee;
     address public repTokenAddress;
     address public ensRegistryAddress;
     address public registrarAddress;

     mapping (address => mapping(uint => address)) lrsPerUser;
     mapping (address => uint) lrsCountPerUser;

     uint public totalLrCount = 0;
     mapping (uint => address) lrs;

     // 0.01 ETH
     uint public borrowerFeeAmount = 10000000000000000;

     modifier byAnyone(){
          _;
     }

     function Ledger(address whereToSendFee_,address repTokenAddress_,address ensRegistryAddress_, address registrarAddress_){
          mainAddress = msg.sender;
          whereToSendFee = whereToSendFee_;
          repTokenAddress = repTokenAddress_;
          ensRegistryAddress = ensRegistryAddress_;
          registrarAddress = registrarAddress_;
     }

     function getRepTokenAddress()constant returns(address out){
          out = repTokenAddress;
          return;
     }

     function getFeeSum()constant returns(uint out){
          out = borrowerFeeAmount;
          return;
     }

     /// Must be called by Borrower
     // tokens as a collateral 
     function createNewLendingRequest()payable byAnyone returns(address out){
          out = newLr(0);
     }

     // domain as a collateral 
     function createNewLendingRequestEns()payable byAnyone returns(address out){
          out = newLr(1);
     }
     // reputation as a collateral
     function createNewLendingRequestRep()payable byAnyone returns(address out){
          out = newLr(2);
     }

     function newLr(int collateralType)payable byAnyone returns(address out){
          // 1 - send Fee to wherToSendFee 
          uint feeAmount = borrowerFeeAmount;
          if(msg.value<feeAmount){
               throw;
          }

          if(!whereToSendFee.call.gas(200000).value(feeAmount)()){
               throw;
          }

          // 2 - create new LR
          // will be in state 'WaitingForData'

          out = new LendingRequest(mainAddress,msg.sender,whereToSendFee,collateralType,ensRegistryAddress,registrarAddress);

          // 3 - add to list
          uint currentCount = lrsCountPerUser[msg.sender];
          lrsPerUser[msg.sender][currentCount] = out;
          lrsCountPerUser[msg.sender]++;

          lrs[totalLrCount] = out;
          totalLrCount++;
     }

     function getLrCount()constant returns(uint out){
          out = totalLrCount;
          return;
     }

     function getLr(uint index) constant returns (address out){
          out = lrs[index];  
          return;
     }

     function getLrCountForUser(address a)constant returns(uint out){
          out = lrsCountPerUser[a];
          return;
     }

     function getLrForUser(address a,uint index) constant returns (address out){
          out = lrsPerUser[a][index];  
          return;
     }

     function getLrFundedCount()constant returns(uint out){
          out = 0;

          for(uint i=0; i<totalLrCount; ++i){
               LendingRequest lr = LendingRequest(lrs[i]);
               if(lr.getState()==LendingRequest.State.WaitingForPayback){
                    out++;
               }
          }

          return;
     }

     function getLrFunded(uint index) constant returns (address out){
          uint indexFound = 0;
          for(uint i=0; i<totalLrCount; ++i){
               LendingRequest lr = LendingRequest(lrs[i]);
               if(lr.getState()==LendingRequest.State.WaitingForPayback){
                    if(indexFound==index){
                         out = lrs[i];
                         return;
                    }

                    indexFound++;
               }
          }
          return;
     }

     function addRepTokens(address potentialBorrower, uint weiSum){
          ReputationTokenInterface repToken = ReputationTokenInterface(repTokenAddress);
          LendingRequest lr = LendingRequest(msg.sender);  
          // we`ll check is msg.sender is a real our LendingRequest
          if(lr.borrower()==potentialBorrower && address(this)==lr.creator()){// we`ll take a lr contract and check address a – is he a borrower for this contract?
               uint repTokens = (weiSum/10);
               repToken.issueTokens(potentialBorrower,repTokens);               
          }
     }

     function lockRepTokens(address potentialBorrower, uint weiSum){
          ReputationTokenInterface repToken = ReputationTokenInterface(repTokenAddress);
          LendingRequest lr = LendingRequest(msg.sender);  
          // we`ll check is msg.sender is a real our LendingRequest
          if(lr.borrower()==potentialBorrower && address(this)==lr.creator()){// we`ll take a lr contract and check address a – is he a borrower for this contract?
               uint repTokens = (weiSum);
               repToken.lockTokens(potentialBorrower,repTokens);               
          }
     }

     function unlockRepTokens(address potentialBorrower, uint weiSum){
          ReputationTokenInterface repToken = ReputationTokenInterface(repTokenAddress);
          LendingRequest lr = LendingRequest(msg.sender);
          // we`ll check is msg.sender is a real our LendingRequest
          if(lr.borrower()==potentialBorrower && address(this)==lr.creator()){// we`ll take a lr contract and check address a – is he a borrower for this contract?
               uint repTokens = (weiSum);
               repToken.unlockTokens(potentialBorrower,repTokens);               
          }
     }

     function burnRepTokens(address potentialBorrower){
          ReputationTokenInterface repToken = ReputationTokenInterface(repTokenAddress);
          LendingRequest lr = LendingRequest(msg.sender);  
          // we`ll check is msg.sender is a real our LendingRequest
          if(lr.borrower()==potentialBorrower && address(this)==lr.creator()){// we`ll take a lr contract and check address a – is he a borrower for this contract?
               repToken.burnTokens(potentialBorrower);               
          }
     }     

     function approveRepTokens(address potentialBorrower,uint weiSum) returns (bool success){
          ReputationTokenInterface repToken = ReputationTokenInterface(repTokenAddress);
          success = repToken.nonLockedTokensCount(potentialBorrower) >= weiSum;
          return;             
     } 

     function() payable{
          createNewLendingRequest();
     }
}

contract LendingRequest is SafeMath {
     string public name = "LendingRequest";
     address public creator = 0x0;
     address public registrarAddress;

     // 0.01 ETH
     uint public lenderFeeAmount   = 10000000000000000;
     
     Ledger ledger;

     // who deployed Ledger
     address public mainAddress = 0x0;


     enum State {
          WaitingForData,

          // borrower set data
          WaitingForTokens,
          Cancelled,

          // wneh tokens received from borrower
          WaitingForLender,

          // when money received from Lender
          WaitingForPayback,

          Default,

          Finished
     }

     enum Type {
          TokensCollateral,
          EnsCollateral,
          RepCollateral
     }

// Contract fields:
     State public currentState = State.WaitingForData;

     Type public currentType = Type.TokensCollateral;

     address public whereToSendFee = 0x0;
     uint public start = 0;

     // This must be set by borrower:
     address public borrower = 0x0;
     uint public wanted_wei = 0;
     uint public token_amount = 0;
     uint public premium_wei = 0;
     string public token_name = "";
     bytes32 public ens_domain_hash; 
     string public token_infolink = "";
     address public token_smartcontract_address = 0x0;
     uint public days_to_lend = 0;

     // this is an address of AbstractENS contract
     address public ensRegistryAddress = 0;

     address public lender = 0x0;
// Access methods:
     function getBorrower()constant returns(address out){
          out = borrower;
     }

     function getWantedWei()constant returns(uint out){
          out = wanted_wei;
     }

     function getPremiumWei()constant returns(uint out){
          out = premium_wei;
     }

     function getTokenAmount()constant returns(uint out){
          out = token_amount;
     }

     function getTokenName()constant returns(string out){
          out = token_name;
     }

     function getTokenInfoLink()constant returns(string out){
          out = token_infolink;
     }

     function getTokenSmartcontractAddress()constant returns(address out){
          out = token_smartcontract_address;
     }

     function getDaysToLen()constant returns(uint out){
          out = days_to_lend;
     }
     
     function getState()constant returns(State out){
          out = currentState;
          return;
     }

     function getLender()constant returns(address out){
          out = lender;
     }

     function isEns()constant returns(bool out){
          out = (currentType==Type.EnsCollateral);
     }

     function isRep()constant returns(bool out){
          out = (currentType==Type.RepCollateral);
     }


     function getEnsDomainHash()constant returns(bytes32 out){
          out = ens_domain_hash;
     }
///

     modifier byAnyone(){
          _;
     }

     modifier onlyByLedger(){
          if(Ledger(msg.sender)!=ledger)
               throw;
          _;
     }

     modifier onlyByMain(){
          if(msg.sender!=mainAddress)
               throw;
          _;
     }

     modifier byLedgerOrMain(){
          if((msg.sender!=mainAddress) && (Ledger(msg.sender)!=ledger))
               throw;
          _;
     }

     modifier byLedgerMainOrBorrower(){
          if((msg.sender!=mainAddress) && (Ledger(msg.sender)!=ledger) && (msg.sender!=borrower))
               throw;
          _;
     }

     modifier onlyByLender(){
          if(msg.sender!=lender)
               throw;
          _;
     }

     modifier onlyInState(State state){
          if(currentState!=state)
               throw;
          _;
     }

     function LendingRequest(address mainAddress_,address borrower_,address whereToSendFee_, int contractType, address ensRegistryAddress_, address registrarAddress_){
          ledger = Ledger(msg.sender);

          mainAddress = mainAddress_;
          whereToSendFee = whereToSendFee_;
          registrarAddress = registrarAddress_;
          borrower = borrower_;
          creator = msg.sender;
          // collateral: tokens or ENS domain?
          if      (contractType==0){
               currentType = Type.TokensCollateral;
          }else if(contractType==1){
               currentType = Type.EnsCollateral;
          }else if(contractType==2){
               currentType = Type.RepCollateral;
          } else {
               throw;
          }

          ensRegistryAddress = ensRegistryAddress_;
     }

     function changeLedgerAddress(address new_)onlyByLedger{
          ledger = Ledger(new_);
     }

     function changeMainAddress(address new_)onlyByMain{
          mainAddress = new_;
     }

// 
     function setData(uint wanted_wei_, uint token_amount_, uint premium_wei_,
          string token_name_, string token_infolink_, address token_smartcontract_address_, uint days_to_lend_, bytes32 ens_domain_hash_) 
               byLedgerMainOrBorrower onlyInState(State.WaitingForData)
     {
          wanted_wei = wanted_wei_;
          premium_wei = premium_wei_;
          token_amount = token_amount_; // will be ZERO if isCollateralEns is true 
          token_name = token_name_;
          token_infolink = token_infolink_;
          token_smartcontract_address = token_smartcontract_address_;
          days_to_lend = days_to_lend_;
          ens_domain_hash = ens_domain_hash_;

          if(currentType==Type.RepCollateral){
               if(ledger.approveRepTokens(borrower, wanted_wei)){
                    ledger.lockRepTokens(borrower, wanted_wei);
                    currentState = State.WaitingForLender;
               }
          } else {
               currentState = State.WaitingForTokens;
          }
     }

     function cancell() byLedgerMainOrBorrower {
          // 1 - check current state
          if((currentState!=State.WaitingForData) && (currentState!=State.WaitingForLender))
               throw;

          if(currentState==State.WaitingForLender){
               // return tokens back to Borrower
               releaseToBorrower();
          }
          currentState = State.Cancelled;
     }

     // Should check if tokens are 'trasferred' to this contracts address and controlled
     function checkTokens()byLedgerMainOrBorrower onlyInState(State.WaitingForTokens){
          if(currentType!=Type.TokensCollateral){
               throw;
          }

          ERC20Token token = ERC20Token(token_smartcontract_address);

          uint tokenBalance = token.balanceOf(this);
          if(tokenBalance >= token_amount){
               // we are ready to search someone 
               // to give us the money
               currentState = State.WaitingForLender;
          }
     }

     function checkDomain() onlyInState(State.WaitingForTokens){
          // Use 'ens_domain_hash' to check whether this domain is transferred to this address
          AbstractENS ens = AbstractENS(ensRegistryAddress);
          if(ens.owner(ens_domain_hash)==address(this)){
               // we are ready to search someone 
               // to give us the money
               currentState = State.WaitingForLender;
               return;
          }
     }

     // This function is called when someone sends money to this contract directly.
     //
     // If someone is sending at least 'wanted_wei' amount of money in WaitingForLender state
     // -> then it means it's a Lender.
     //
     // If someone is sending at least 'wanted_wei' amount of money in WaitingForPayback state
     // -> then it means it's a Borrower returning money back. 
     function() payable {
          if(currentState==State.WaitingForLender){
               waitingForLender();
          }else if(currentState==State.WaitingForPayback){
               waitingForPayback();
          }
     }

     // If no lenders -> borrower can cancel the LR
     function returnTokens() byLedgerMainOrBorrower onlyInState(State.WaitingForLender){
          // tokens are released back to borrower
          releaseToBorrower();
          currentState = State.Finished;
     }

     function waitingForLender()payable onlyInState(State.WaitingForLender){
          if(msg.value<safeAdd(wanted_wei,lenderFeeAmount)){
               throw;
          }

          // send platform fee first
          if(!whereToSendFee.call.gas(200000).value(lenderFeeAmount)()){
               throw;
          }

          // if you sent this -> you are the lender
          lender = msg.sender;     

          // ETH is sent to borrower in full
          // Tokens are kept inside of this contract
          if(!borrower.call.gas(200000).value(wanted_wei)()){
               throw;
          }

          currentState = State.WaitingForPayback;

          start = now;
     }

     // if time hasn't passed yet - Borrower can return loan back
     // and get his tokens back
     // 
     // anyone can call this (not only the borrower)
     function waitingForPayback()payable onlyInState(State.WaitingForPayback){
          if(msg.value<safeAdd(wanted_wei,premium_wei)){
               throw;
          }
          // ETH is sent back to lender in full with premium!!!
          if(!lender.call.gas(2000000).value(msg.value)()){
               throw;
          }

          releaseToBorrower(); // tokens are released back to borrower
          ledger.addRepTokens(borrower,wanted_wei);
          currentState = State.Finished; // finished
     }

     // How much should lender send
     function getNeededSumByLender()constant returns(uint out){
          uint total = safeAdd(wanted_wei,lenderFeeAmount);
          out = total;
          return;
     }

     // How much should borrower return to release tokens
     function getNeededSumByBorrower()constant returns(uint out){
          uint total = safeAdd(wanted_wei,premium_wei);
          out = total;
          return;
     }

     // After time has passed but lender hasn't returned the loan -> move tokens to lender
     // anyone can call this (not only the lender)
     function requestDefault()onlyInState(State.WaitingForPayback){
          if(now < (start + days_to_lend * 1 days)){
               throw;
          }

          releaseToLender(); // tokens are released to the lender        
          // ledger.addRepTokens(lender,wanted_wei); // Only Lender get Reputation tokens
          currentState = State.Default; 
     }

     function releaseToLender() internal {
    
          if(currentType==Type.EnsCollateral){
               AbstractENS ens = AbstractENS(ensRegistryAddress);
               Registrar registrar = Registrar(registrarAddress);

               ens.setOwner(ens_domain_hash,lender);
               registrar.transfer(ens_domain_hash,lender);

          }else if (currentType==Type.RepCollateral){
               ledger.unlockRepTokens(borrower, wanted_wei);
          }else{
               ERC20Token token = ERC20Token(token_smartcontract_address);
               uint tokenBalance = token.balanceOf(this);
               token.transfer(lender,tokenBalance);
          }

          ledger.burnRepTokens(borrower);
     }

     function releaseToBorrower() internal {
          if(currentType==Type.EnsCollateral){
               AbstractENS ens = AbstractENS(ensRegistryAddress);
               Registrar registrar = Registrar(registrarAddress);
               ens.setOwner(ens_domain_hash,borrower);
               registrar.transfer(ens_domain_hash,borrower);

          }else if (currentType==Type.RepCollateral){
               ledger.unlockRepTokens(borrower, wanted_wei);
          }else{
               ERC20Token token = ERC20Token(token_smartcontract_address);
               uint tokenBalance = token.balanceOf(this);
               token.transfer(borrower,tokenBalance);
          }
     }
}

