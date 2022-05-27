// SPDX-License-Identifier: MIT
pragma solidity ^0.6.6;

import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";
import "@chainlink/contracts/src/v0.6/vendor/SafeMathChainlink.sol";


contract Insurance {


uint public probability;
uint public sum_insured; //in USD
uint public premium;     //in USD
uint public hasclaimed;
using SafeMathChainlink for uint256;
AggregatorV3Interface internal priceFeed = AggregatorV3Interface(0x9326BFA02ADD2366b30bacB125260Af641031331);    
struct Person {
    string name;
    //uint balance;
    bool claim;
    
}
uint public N;
uint public c;
bool public ycl;
address claimed;
uint public deadline;
uint public starttime;

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
   function premium_in_wei () public  view returns (uint) {
        return etherToWei(premium)/uint256(getLatestPrice());
    }
    function etherToWei(uint v) public pure returns (uint)
    {
       return v*(10**18);
    }
    function sum_insured_in_wei () public  view returns (uint) {
        return etherToWei(sum_insured)/uint256(getLatestPrice());
    }
mapping (address => Person) public members;
address[] public Addresses;

constructor () public {
    starttime = now;
    deadline = now + 365* 1 days;
    
}
function Set_Probablity (uint _probability) public {
    require(_probability > 0, "probability must be greater than 0");
    require(_probability < 100, "probability must be smaller than 100");
    probability = _probability;
}

function SetInsured_Sum  (uint _sum_insured) public {
    require (_sum_insured >0, "insured sum must be greater than 0");
    require ((_sum_insured*probability) > 100, "insured sum too low");
    sum_insured = _sum_insured;
}


function CalculatePremium () public  {
    premium = sum_insured*probability/100;
}
function AddMember (string memory _name) public payable {

    address _address;
    _address=msg.sender;
    require (msg.value == premium_in_wei(), "deposit must be equal to premium in wei");
    members[_address].name = _name;
    Addresses.push(msg.sender);
    N++;
}



function getBalance () public view returns(uint256) {
    return address(this).balance;
}

function Claim ()  public  {
    
    address _address;
    _address=msg.sender;
    
    require ((N*premium >= sum_insured), "too little members");
    require (address(this).balance >= sum_insured_in_wei(), "claims limit has been used");
    require(members[_address].claim == false, "You can only claim once");

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
    
    require(members[msg.sender].claim == false , "cannot vote to own claim");
    if (v==true) {
        c++;
    }
}   
    function Calculate_Vote () public  returns (bool) 
    { if (c*100/(N-1) > 50  ) {
        c=0;
        hasclaimed++;
        Withdraw (claimed);
        return true;
    }

    else return false;
}
function Withdraw (address _address) public  {
    
    (bool success, ) = _address.call{value: sum_insured_in_wei()}("");
    claimed=address(0x0);
    
    ycl=false;
}
function WithdrawAll () public {
    require (deadline == now);
    require (Addresses.length>0);
    uint rest;
    rest=address(this).balance/(N-hasclaimed);
    for (uint i=0; i<=Addresses.length-1; i++) {
        require (members[Addresses[i]].claim = false);
         (bool success, ) = Addresses[i].call{value: rest}("");
    }


}

}