pragma solidity ^0.4.21;
 
contract BusinessCard {
    
    mapping (bytes32 => string) data;
    
    address owner;
    
    function BusinessCard() public {
        owner = msg.sender;
    }
    
    function setData(string key, string value) public {
        require(msg.sender == owner);
        data[keccak256(key)] = value;
    }
    
    function getData(string key) public constant returns(string) {
        return data[keccak256(key)];
    }
 
}