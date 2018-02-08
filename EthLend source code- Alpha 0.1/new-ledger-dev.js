var solc             = Npm.require('solc');
var fs               = Npm.require('fs');
var BigNumber        = Npm.require('bignumber.js');
var path             = Npm.require('path');
var base             =  path.resolve('.').split('.meteor')[0];
var Ω                = console.log;
var creator          = '0xb9af8aa42c97f5a1f73c6e1a683c4bf6353b83e7';
var contract_address = '0x185dd613715258688B8c903e5b46CaD63c943681';
var node             = 'http://52.213.65.90:8545';
var contract         = '';
var Web3             = Npm.require('web3');
this.web3            = new Web3(new Web3.providers.HttpProvider(node));
this.step            = {};
this.deployResp=(creator,ledgerAbi,ledgerBytecode,cb)=> {
     var tempContract     = web3.eth.contract(ledgerAbi);
     var whereToSendMoney = creator;
     var params = { from: creator, gas: 4005000, gasPrice:150000000000,  data: `0x${ledgerBytecode}`}
     tempContract.new(whereToSendMoney, params, (err, c)=> {
          if(err){ Ω('ERROR: ' + err); return cb(err) }
          return cb(null, c.transactionHash)
     });
}

this.getContractAbi = (cName)=> (filename)=> (cb)=> fs.readFile(filename, (err, res)=>{ 
     if (err) return cb(err)
     var source   = res.toString();
     var output   = solc.compile(source, 1);
     var abi      = JSON.parse(output.contracts[cName].interface);
     var bytecode = output.contracts[cName].bytecode;
     return cb(null,abi,bytecode);
});

this.getInterface =(cName,filename,cb)=> fs.readFile(base+'ethlend/server/'+filename, 'utf8', (err, res)=>{ 
     if (err) return cb(err);    
     var source = res.toString();
     var output   = solc.compile(source, 1);
     console.log('file:', output)
     cb(null,output.contracts)
});

this.Create =(repAddress,cb)=>{
     console.log('base:',base)
     web3.eth.getAccounts((err, as)=> {
          console.log('as: '+as)
          if(err) { return cb(err)}
          getContractAbi(':SampleToken')(base+'ethlend/server/SampleToken.sol')((err,ledgerAbi,ledgerBytecode)=> {
               if(err) { return cb(err)}
               console.log('got contract abi')
               deployMain(creator, repAddress, ledgerAbi,ledgerBytecode, (err,res)=>{
                    console.log('deployed: '+res )
                    if(err) { return cb(err)}
                    return cb(null,res)
               })
          });
     });
}

this.DeployRepContract =(cb)=>{
     console.log('base:',base)
     web3.eth.getAccounts((err, as)=> {
          console.log('as: ',as)
          if(err) { return cb(err)}
          getContractAbi(':ReputationToken')(base+'ethlend/server/ReputationToken.sol')((err,ledgerAbi,ledgerBytecode)=> {
               if(err) { return cb(err)}
               console.log('got rep abi')
               deployResp(creator, ledgerAbi, ledgerBytecode, (err,res)=>{
                    console.log('deployed: '+res )
                    if(err) { return cb(err)}
                    return cb(null,res)
               })
          });
     });
}

this.deployMain=(creator,repAddress,ledgerAbi,ledgerBytecode,cb)=> {
     var tempContract     = web3.eth.contract(ledgerAbi);
     var whereToSendMoney = creator;
     var params = { from: creator, gas: 4005000, gasPrice:150000000000, data: `0x${ledgerBytecode}`}
     tempContract.new(whereToSendMoney, repAddress, params, (err, c)=> {
          if(err){ Ω('ERROR: ' + err); return cb(err) }
          return cb(null, c.transactionHash)
     });
}

// DeployContract(config.TONY_ADDRESS, config.REP_ADDRESS, config.ENS_REG_ADDRESS, conscb)
// changeCreator(config.REP_ADDRESS, config.MAIN_ADDRESS, conscb)


this.DeployContract =(creatr, repAddress, ensA, cb)=>{
     getContractAbi(':Ledger')(base+'ethlend/server/EthLend.sol')((err,ledgerAbi,ledgerBytecode)=> {
          if(err) { return cb(err)}
          console.log('got contract abi')

          var tempContract   = web3.eth.contract(ledgerAbi);
          var params = { from: creatr, gas: 4005000, gasPrice:150000000000, data: `0x${ledgerBytecode}`}
          tempContract.new(creatr, repAddress, ensA, params, (err, c)=> {
               if(err){ Ω('ERROR: ' + err); return cb(err) }
               return cb(null, c.transactionHash)
          });
     });
}




this.DeploySampleContract =(cb)=>{
     getContractAbi(':SampleToken')(base+'ethlend/server/SampleToken.sol')((err,Abi,Bytecode)=> {
          if(err) { return cb(err)}
          console.log('got contract abi')

          var tempContract   = web3.eth.contract(ledgerAbi);
          var params = { from: creatr, gas: 4005000, gasPrice:150000000000, data: `0x${Bytecode}`}
          tempContract.new(params, (err, c)=> {
               if(err){ Ω('ERROR: ' + err); return cb(err) }
               return cb(null, c.transactionHash)
          });
     });
}

this.DeployENS =(cb)=>{
     getContractAbi(':TestENS')(base+'ethlend/server/ENS.sol')((err,abi,Bytecode)=> {
          if(err) { return cb(err)}
          console.log('got contract abi')

          var tempContract   = web3.eth.contract(abi);
          var params = { from: '0xb9Af8aA42c97f5A1F73C6e1a683c4Bf6353B83E7', gas: 2000000, gasPrice:200000000000, data: `0x${Bytecode}`}
          console.log('params:', params)
          tempContract.new(params, (err, c)=> {
               if(err){ Ω('ERROR: ' + err); return cb(err) }
               return cb(null, c.transactionHash)
          });

     });
}

this.changeCreator =(repAddress, contrAddress, cb)=>{
     getContractAbi(':ReputationToken')(base+'ethlend/server/ReputationToken.sol')((err,abi,ledgerBytecode)=> {
          if (err){console.log('err:::',err); return err}
          contract = web3.eth.contract(abi).at(repAddress);
          var params   = { from: config.TONY_ADDRESS, gas: 2000000, gasPrice:20000000000 };
          contract.changeCreator(contrAddress, params, cb);
     });
}

this.call_API_method = (func)=>(A)=>{
     getContractAbi(':SampleToken')(base+'ethlend/server/SampleToken.sol')((err,ledgerAbi,ledgerBytecode)=> {
          if (err){console.log('err:::',err); return err}
          contract = web3.eth.contract(ledgerAbi).at(contract_address);
          func(contract, A)
     });
};

this.issueTokens = (contract,A)=> {
     var params   = { from: creator, gas: 2000000 };

     contract.issueTokens(A.address, A.token_count, params, (err,res)=>{
          if(err) { return A.cb(err)}
          var out = {
               tx: res,
               txLink: 'https://etherscan.io/tx/'+res
          }
          return A.cb(null, out)
     });
}

this.issue = (address, token_count)=> {
     getContractAbi(':SampleToken')(base+'ethlend/server/SampleToken.sol')((err,Abi,ledgerBytecode)=> {
          if (err){console.log('err:::',err); return err}
          contract = web3.eth.contract(Abi).at('0x735F9b02c76602a837f1Bc614f8fF8D91668E919');
          contract.issueTokens(address, token_count, { from: '0xb9af8aa42c97f5a1f73c6e1a683c4bf6353b83e7', gas: 4000000 }, conscb )
     });
};

this.transfer = (contract,A)=> {
     var params   = { from: creator, gas: 2000000 };

     contract.transfer(A.address, A.token_count, params, (err,res)=>{
          if(err) { return A.cb(err)}
          var out = {
               tx: res,
               txLink: 'https://etherscan.io/tx/'+res
          }
          return A.cb(null, out)
     });
}

this.setParams = (contract_address, node, fee, enabled, repAddress, ensAddress)=> { //creator=0x5f6B5B7D4b99bC78AA622E50115628cd247B9A15
     fs.writeFileSync(base+'ethlend/config-other-params.ls',   
          `config.ETH_MAIN_ADDRESS = '${contract_address}'\n` +
          `config.ETH_MAIN_ADDRESS_LINK = 'https://etherscan.io/address/${contract_address}'\n` +
          `config.BALANCE_FEE_AMOUNT_IN_WEI = ${fee}\n` +
          `config.ETH_NODE = '${node}'\n` +
          `config.SMART_CONTRACTS_ENABLED = ${enabled}\n` +
          `config.REPUTATION_ADDRESS = ${repAddress}\n` + 
          `config.ENS_REG_ADDRESS    = ${ensAddress}`
     );
};

this.recompileAbi = ()=> {
     getContractAbi(':Ledger')(base+'ethlend/server/EthLend.sol')((err,ledgerAbi,ledgerBytecode,abiJsonLedger)=>{
          if (err){ console.log('err:::',err); return err }

          getContractAbi(':LendingRequest')(base+'ethlend/server/EthLend.sol')((err,lrAbi,lrBytecode,abiJsonLr)=>{
               if (err){ console.log('err:::',err); return err }

               getContractAbi(':ReputationToken')(base+'ethlend/server/ReputationToken.sol')((err,repAbi,repBytecode,abiJsonRep)=>{
                    if (err){ console.log('err:::',err); return err }

                    getContractAbi(':TestENS')(base+'ethlend/server/ENS.sol')((err,ensAbi,ensBytecode,abiJsonTestENS)=>{
                         if (err){ console.log('err:::',err); return err }

                         getContractAbi(':SampleToken')(base+'ethlend/server/SampleToken.sol')((err,sampleAbi,sampleBytecode,abiJsonSample)=>{
                              if (err){ console.log('err:::',err); return err }

                              getContractAbi(':Registrar')(base+'ethlend/server/ENS.sol')((err,registrarAbi,registrarBytecode,abiJsonReg)=>{
                                   if (err){ console.log('err:::',err); return err }


                                        fs.writeFileSync(base+'ethlend/config-abi.ls',   
                                             `config.LEDGER-ABI    = ${JSON.stringify(ledgerAbi)}\n`+
                                             `config.LR-ABI        = ${JSON.stringify(lrAbi)}\n`+
                                             `config.ENS-ABI       = ${JSON.stringify(ensAbi)}\n`+
                                             `config.SAM-ABI       = ${JSON.stringify(sampleAbi)}\n`+
                                             `config.REP-ABI       = ${JSON.stringify(repAbi)}\n`+
                                             `config.REGISTRAR-ABI = ${JSON.stringify(registrarAbi)}\n\n`+

                                             `config.LEDGER-BCODE    = '0x${ledgerBytecode}'\n`+
                                             `config.LR-BCODE        = '0x${lrBytecode}'\n`+
                                             `config.ENS-BCODE       = '0x${ensBytecode}'\n`+
                                             `config.SAM-BCODE       = '0x${repBytecode}'\n`+
                                             `config.REP-BCODE       = '0x${sampleBytecode}'\n` +  
                                             `config.REGISTRAR-BCODE = '0x${registrarBytecode}'\n`                               
                                        );
                                   console.log('Config at ethlend/config-abi.ls has written');
                              });
                         });
                    });
               });
          });
     });
};

addresscb =(err,res)=> console.log('transactionHash:',res.transactionHash,'address:',res.address)


this.step.deploySample    =()=> DeploySampleContract(addresscb)

this.step.recompileAbi    =()=> recompileAbi()
this.step.deployENS       =()=> DeployENS(addresscb)
this.step.deployRep       =()=> DeployRepContract(addresscb)
this.step.deployRegistrar =()=> web3.eth.contract(config.REGISTRARABI).new({ from: config.TONY_ADDRESS, gas: 4005000, gasPrice:150000000000, data: config.REGISTRARBCODE}, addresscb)
//config-params!
this.step.deployContract  =()=> web3.eth.contract(config.LEDGERABI).new(config.TONY_ADDRESS, config.REP_ADDRESS, config.ENS_REG_ADDRESS, config.REGISTRAR_ADDRESS, { from: config.TONY_ADDRESS, gas: 4005000, gasPrice:150000000000, data: config.LEDGERBCODE}, addresscb)
//config-params!
this.step.changeCreator   =()=> web3.eth.contract(config.REPABI).at(config.REP_ADDRESS).changeCreator(config.ETH_MAIN_ADDRESS, {from:config.TONY_ADDRESS, gas: 2000000, gasPrice:20000000000}, conscb)


Meteor.methods({
     'issue': (address, token_count)=>call_API_method(issueTokens)({
          address:     address, 
          token_count: token_count, 
          cb:          conscb
     }),

     'transfer': (address, token_count)=>call_API_method(transfer)({
          address:     address, 
          token_count: token_count, 
          cb:          conscb
     })
})