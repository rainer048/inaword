pragma solidity 0.4.21;


contract BusinessCard {

    mapping (bytes32 => string) public data;

    function setData(string key, string value) public {
        data[keccak256(key)] = value;
    }

    function getData(string key) public view returns(string) {
        return data[keccak256(key)];
    }
}
