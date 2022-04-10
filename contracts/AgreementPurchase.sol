// SPDX-License-Identifier: MIT
//developed by Osama Rizk
pragma solidity >=0.4.22 <0.9.0;

contract AgreementPurchase {
    address payable public buyer;
    address payable public seller;
    uint256 public value;
    uint256 public shippedMaxTime;
    uint256 public confirmReceiveMaxTime;

    enum State { Created, Locked, Shipped ,Released, Inactive }
    State public state;
// SAFE REMOTE PURCHASE Smart Contract, by Osama Rizk
    constructor(uint _shippedMaxTime,uint _confirmReceiveMaxTime) payable {
        seller=payable(msg.sender);
        value=(msg.value /2);
        shippedMaxTime =block.timestamp + _shippedMaxTime;
        confirmReceiveMaxTime= block.timestamp +  _confirmReceiveMaxTime;
    }
    /// that function can not be called at the current state
    error InvalidState();
    /// only the buyer can call that fuction
    error onlyBuyerErr();
     /// only the seller can call that fuction
    error onlySellerErr();

    

    modifier inState(State _state) {
        if (state != _state) {
            revert  InvalidState();
        }
        _;
    }

    modifier onlyBuyer() {
        if(msg.sender != buyer) {
            revert onlyBuyerErr();
        }
        _;
    }

    modifier onlySeller() {
        if(msg.sender != seller) {
            revert onlySellerErr();
        }
        _;
    }

    /// the shipped max time has expired


    error shippedMaxTimeErr();

    modifier shippedMaxTimeExp() {
        if (block.timestamp >= shippedMaxTime) {
            buyer.transfer(value * 2);
            seller.transfer(value * 2);
            state=State.Inactive;
            errorMsg();
        }

        _;

    } 

    function errorMsg() private   view inState(State.Shipped)  returns (string memory ) {

            return "Shipped Max time has expired";

    }
    function confirmPurchase() public payable inState(State.Created) {
        require((msg.value == value * 2 ), "Please send 2x the purchase amount");
        buyer=payable(msg.sender);
        state=State.Locked;
    }
    function shipping() public inState(State.Locked) onlySeller() shippedMaxTimeExp() {
        
        state=State.Shipped;
        
    }
    function confirmReceived() public inState(State.Shipped) onlyBuyer() {
        if (block.timestamp >= confirmReceiveMaxTime) {
            buyer.transfer(value * 2);
            seller.transfer(value * 2);
            state=State.Inactive;
        }
        else {
        state=State.Released;
        buyer.transfer(value);
        _paySeller();
        }

    }

    function unConfirmedReceiveBuyer() public inState(State.Shipped) onlyBuyer() {
         buyer.transfer(value * 2);

    }

     function unConfirmedReceiveSeller() public inState(State.Shipped) onlySeller() {
         seller.transfer(value * 2);
         state=State.Inactive;

    }

    function _paySeller() internal {
        seller.transfer(value * 3);
         state=State.Inactive;

    }

    function contractBalance() public view onlySeller() returns(uint256) {
        return address(this).balance;
    }
    
}