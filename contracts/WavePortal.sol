// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "hardhat/console.sol";

contract WavePortal {
  uint totalWaves;
  uint private seed;

  struct Wave {
    address waver; 
    string message;
    uint timestamp;
  }

  // declare a variable waves that lets me store an array of structs. this is what lets us hold all the waves anyone sends to us
  Wave[] waves;

  // event that takes in address from whoever waved, timestamp, and the message
  event NewWave(address indexed from, uint timestamp, string message);

  // This is an address => uint mapping, meaning I can associate an address with a number. In this case, I'll be storing the address w/ the last time the user waved at us.
  mapping(address => uint) public lastWavedAt;

  constructor() payable {
    console.log("we have been constructed");
  }

  // we delta'd the wave function a little as well and now it requires a string called message. This is the message our user sends us from the frontend.
  function wave(string memory _message) public {
    // we need to make sure the current timestamp is at least 15-minutes bigger than the last timestamp we stored.
    require(lastWavedAt[msg.sender] + 30 seconds < block.timestamp, "Wait 30sec");

    // update the current timestamp we have for the user.
    lastWavedAt[msg.sender] = block.timestamp;

    // this would be a place to add SafeMath
    totalWaves += 1;
    console.log("%s waved w/ message %s", msg.sender, _message);
    console.log("Got message: %s", _message);

    // this is where we store the wave data in the array
    waves.push(Wave(msg.sender, _message, block.timestamp));

    // emit data on the new wave
    emit NewWave(msg.sender, block.timestamp, _message);

    // generate a pseudo random number in the range of 100
    uint randomNumber = (block.difficulty + block.timestamp + seed) % 100;
    console.log("random # generated: %s", randomNumber);

    // set the generated random number as the seed for the next wave
    seed = randomNumber;

    // give a 5% chance that the user wins the prize
    if(randomNumber < 5) {
      console.log("%s won!", msg.sender);
      uint prizeAmount = 0.0001 ether;
      require(prizeAmount <= address(this).balance, "Trying to withdraw more money than the contract has.");
      (bool success,) = (msg.sender).call{value: prizeAmount}("");
      require(success, "Failed to withdraw money from contract.");
    }
  }

  // add function totalWaves which returns the struct array waces to us. this makes it easy to retrieve the waves from our website
  function getAllWaves() view public returns (Wave[] memory) {
    return waves;
  }

  // DOES THIS UINT NEED TO BE UINT256?
  function getTotalWaves() view public returns (uint) {
    return totalWaves;
  }
}