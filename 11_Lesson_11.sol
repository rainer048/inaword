pragma solidity 0.4.21;


contract ERC20Basic {

    uint256 public totalSupply;

    function balanceOf(address who) public constant returns (uint256);
    function transfer(address to, uint256 value) public returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

}


contract ERC20 is ERC20Basic {

    function allowance(address owner, address spender) public constant returns (uint256);
    function transferFrom(address from, address to, uint256 value) public returns (bool);
    function approve(address spender, uint256 value) public returns (bool);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}


library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }

}


contract BasicToken is ERC20Basic {

    using SafeMath for uint256;

    mapping(address => uint256) public balances;

    function transfer(address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));
        require(_value <= balances[msg.sender]);

        // SafeMath.sub will throw if there is not enough balance.
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function balanceOf(address _owner) public view returns (uint256 balance) {
        require(_owner != address(0));

        return balances[_owner];
    }
}


contract StandardToken is ERC20, BasicToken {

    mapping (address => mapping (address => uint256)) public allowed;

    function () public payable {
        revert();
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        require(_from != address(0));
        require(_to != address(0));
        require(_value <= balances[_from]);
        require(_value <= allowed[_from][msg.sender]);

        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        emit Transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool) {
        require(_spender != address(0));
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
        require(_owner != address(0));
        require(_spender != address(0));

        return allowed[_owner][_spender];
    }

    function increaseApproval (address _spender, uint _addedValue) public returns (bool success) {
        require(_spender != address(0));

        allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

    function decreaseApproval (address _spender, uint _subtractedValue) public returns (bool success) {
        require(_spender != address(0));

        uint oldValue = allowed[msg.sender][_spender];
        if (_subtractedValue > oldValue) {
            allowed[msg.sender][_spender] = 0;
        } else {
            allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
        }
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

}


contract Ownable {

    address public owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function Ownable() public {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));

        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

}


contract MintableToken is StandardToken, Ownable {

    bool public mintingFinished = false;
    address public saleAgent;

    event Mint(address indexed to, uint256 amount);
    event MintFinished();

    function setSaleAgent(address newSaleAgnet) public {
        require(newSaleAgnet != address(0));
        require(msg.sender == saleAgent || msg.sender == owner);

        saleAgent = newSaleAgnet;
    }

    function mint(address _to, uint256 _amount) public returns (bool) {
        require(_to != address(0));
        require(msg.sender == saleAgent && !mintingFinished);

        totalSupply = totalSupply.add(_amount);
        balances[_to] = balances[_to].add(_amount);
        emit Mint(_to, _amount);
        return true;
    }

    function finishMinting() public returns (bool) {
        require((msg.sender == saleAgent || msg.sender == owner) && !mintingFinished);

        mintingFinished = true;
        emit MintFinished();
        return true;
    }


}


contract BestTokenCoin is MintableToken {

    string public constant name = "Best Coin Token";
    string public constant symbol = "BCT";
    uint32 public constant decimals = 18;

    function BestTokenCoin() public {
        setSaleAgent(msg.sender);
    }

}


contract Crowdsale is Ownable {

    using SafeMath for uint;

    address public multisig;
    address public restricted;

    uint public restrictedPercent;
    uint public start;
    uint public period;
    uint public hardcap;
    uint public rate;
    uint public softcap;

    BestTokenCoin public token = new BestTokenCoin();

    function Crowdsale() public {
        multisig = 0xEA15Adb66DC92a4BbCcC8Bf32fd25E2e86a2A770;
        restricted = 0xb3eD172CC64839FB0C0Aa06aa129f402e994e7De;
        restrictedPercent = 30;
        rate = 100000000000000000000;
        start = 1522540800;
        period = 30;
        hardcap = 10000000000000000000000;
        softcap = 10000000000000000000;
    }

    modifier saleIsOn() {
        require(now > start && now < start + period * 1 days);
        _;
    }

    modifier isUnderHardCap() {
        require(multisig.balance <= hardcap);
        _;
    }

    function() external payable {
        createTokens();
    }

    function finishMinting() public onlyOwner {
        if (this.balance >= softcap) {
            multisig.transfer(this.balance);
            uint issuedTokenSupply = token.totalSupply();
            uint restrictedTokens = issuedTokenSupply.mul(restrictedPercent).div(100 - restrictedPercent);
            token.mint(restricted, restrictedTokens);
            token.finishMinting();
        }
    }

    function refund() public {
        require(this.balance < softcap && now > start + period * 1 days);
        uint value = balances[msg.sender];
        balances[msg.sender] = 0;
        msg.sender.transfer(value);

    }

    function createTokens() public isUnderHardCap saleIsOn payable {
        uint tokens = rate.mul(msg.value).div(1 ether);
        uint bonusTokens = 0;
        if (now < start + (period * 1 days).div(4)) {
            bonusTokens = tokens.div(4);
        } else if (now < start + (period * 1 days).div(2)) {
            bonusTokens = tokens.div(10);
        } else if (now < start + (period * 1 days).div(4).mul(3)) {
            bonusTokens = tokens.div(20);
        }
        tokens += bonusTokens;
        token.mint(msg.sender, tokens);
        balances[msg.sender] = balances[msg.sender].add(msg.value);
    }

}
