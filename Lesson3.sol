pragma solidity 0.4.21;


contract BusinessCard {

    mapping (bytes32 => string) public data;

    address public owner;

    function BusinessCard() public {
        owner = msg.sender;
    }

    function setData(string key, string value) public {
        require(msg.sender == owner);
        data[keccak256(key)] = value;
    }

    function getData(string key) public view returns(string) {
        return data[keccak256(key)];
    }
}
