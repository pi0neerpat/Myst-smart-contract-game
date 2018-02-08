pragma solidity ^0.4.11;

contract AbstractENS {
     function owner(bytes32) constant returns(address){ 
          return 0;
     }

     function resolver(bytes32) constant returns(address){ 
          return 0;
     }

     function ttl(bytes32) constant returns(uint64){ 
          return 0;
     }
     function setOwner(bytes32, address){

     }

     function setSubnodeOwner(bytes32, bytes32, address){

     }

     function setResolver(bytes32, address){

     }

     function setTTL(bytes32, uint64){
          
     }

     // Logged when the owner of a node assigns a new owner to a subnode.
     event NewOwner(bytes32 indexed node, bytes32 indexed label, address owner);

     // Logged when the owner of a node transfers ownership to a new account.
     event Transfer(bytes32 indexed node, address owner);

     // Logged when the resolver for a node changes.
     event NewResolver(bytes32 indexed node, address resolver);

     // Logged when the TTL of a node changes
     event NewTTL(bytes32 indexed node, uint64 ttl);
}

contract TestENS is AbstractENS {

     mapping (bytes32 => address) hashToOwner;

     function owner(bytes32 node) constant returns(address out){
          out = hashToOwner[node];
          return;
     }

     function setOwner(bytes32 node, address o){
          hashToOwner[node] = o;
     } 
     
}

contract Registrar {

     function transfer(bytes32, address){
          return;
     } 

}