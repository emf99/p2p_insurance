pragma solidity ^0.6.6;

import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";
import "@chainlink/contracts/src/v0.6/vendor/SafeMathChainlink.sol";


contract Insurance {

using SafeMathChainlink for uint256;
AggregatorV3Interface internal priceFeed = AggregatorV3Interface(0x9326BFA02ADD2366b30bacB125260Af641031331);    
struct Person {
    string name;
    uint collection;
    bool claim;
}
uint public i;
uint public c;
//mapping (bool => adresses) clamises;
bool public ycl;
address claimed;

function getLatestPrice() public view returns (int) {
   (
       uint80 roundID, 
       int price,
       uint startedAt,
       uint timeStamp,
       uint80 answeredInRound
    ) = priceFeed.latestRoundData();
    return price/10**8;
}
    function ETH2dollars (uint _i) public view returns (uint) {
        return _i*uint(getLatestPrice())/100000000;
    }
mapping (address => Person) public members;
function AddMember (string memory _name) public {

    address _address;
    _address=msg.sender;
    members[_address].name = _name;
    i++;
}



function deposit () public payable {
   require (ETH2dollars(msg.value) > 100, "at least 100 $");
   members[msg.sender].collection=msg.value;
}
function getBalance () public view returns(uint256) {
    return address(this).balance;
}

function Claim ()  public  {
    
    address _address;
    _address=msg.sender;
    require(members[_address].collection > 0);
    require(members[_address].claim == false);
    members[_address].claim = true;
    ycl=true;
    claimed=msg.sender;
    
   
    
}
struct Voter {
    bool voted;
    address _address;
}

function Vote ( bool  v) public {
    
    require(ycl==true);
    
    require(members[msg.sender].collection > 0, "musi wplacic");
    require(members[msg.sender].claim == false , "nie moze claim");
    if (v==true) {
        c++;
    }
}   
    function calculate () public  returns (bool) 
    { if (c*100/i > 50  ) {
        c=0;
        Withdraw (claimed, address(this).balance);
        return true;
    }

    else return false;
}
function Withdraw (address _address, uint _i) public  {
    (bool success, ) = _address.call{value: _i}("");
    claimed=address(0x0);
    
    ycl=false;
}


}