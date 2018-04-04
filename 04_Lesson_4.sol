pragma solidity 0.4.21;


contract Ownable {

    address public owner;

    function Ownable() public {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        owner = newOwner;
    }
}


contract BusinessCard is Ownable {

    mapping (bytes32 => string) public data;

    function setData(string key, string value) public onlyOwner {
        data[keccak256(key)] = value;
    }

    function getData(string key) public view returns(string) {
        return data[keccak256(key)];
    }
}
