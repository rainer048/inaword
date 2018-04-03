pragma solidity ^0.4.21;

contract HelloWorld {
    
    string name;

    function setData(string _name) public {
        name = _name;
    }
    
    function getData() public view returns (string) {
        return name;
    }
    
}