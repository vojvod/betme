pragma solidity ^0.4.24;

contract Betme
{
    address private _owner;
    uint private nonce;

    struct BetDetails {
        uint _timestamp;
        string _theBet;
        uint _amount;
        address _betWitness;
        address _betparticipantOne;
        address _betparticipantTwo;
        uint _theWinner;
    }

    mapping(bytes32 => BetDetails) _bets;

    modifier validValue() {
        require(msg.value > 10000000000000000);
        _;
    }

    modifier validWitness(address betWitness, bytes32 betID, uint wn) {
        require(_bets[betID]._betWitness == betWitness);
        require(_bets[betID]._theWinner == 0);
        require(wn == 1 || wn == 2);
        _;
    }

    modifier validParticipants(bytes32 betID, address betParticipant){
        require(_bets[betID]._betWitness == betParticipant || _bets[betID]._betparticipantOne == betParticipant || _bets[betID]._betparticipantTwo == betParticipant);
        _;
    }

    constructor() public {
        _owner = msg.sender;
    }

    function() public payable {}

    function createBet(string theBet, uint amount, address betWitness, address betparticipantOne, address betparticipantTwo) validValue public payable returns(bytes32 betID) {
        bytes32 unique = keccak256(abi.encodePacked(nonce++, theBet));
        _bets[unique] = BetDetails(block.timestamp, theBet, amount, betWitness, betparticipantOne, betparticipantTwo, 0);
        _owner.transfer(msg.value);
        address(this).transfer(amount);
        return (unique);
    }

    function getBet(bytes32 betID, address betParticipant) validParticipants(betID, betParticipant) public constant returns (
        uint timestamp,
        string theBet,
        uint amount,
        address betWitness,
        address betparticipantOne,
        address betparticipantTwo,
        uint theWinner
    ) {
        BetDetails memory betDetails = _bets[betID];
        return (
        betDetails._timestamp,
        betDetails._theBet,
        betDetails._amount,
        betDetails._betWitness,
        betDetails._betparticipantOne,
        betDetails._betparticipantTwo,
        betDetails._theWinner
        );
    }

    function setWinner(bytes32 betID, uint wn) validWitness(msg.sender, betID, wn) public {
        _bets[betID]._theWinner = wn;
        if(wn == 1){
            _bets[betID]._betparticipantOne.transfer(_bets[betID]._amount);
        }
        else if(wn == 2){
            _bets[betID]._betparticipantTwo.transfer(_bets[betID]._amount);
        }
    }

}
