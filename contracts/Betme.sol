pragma solidity ^0.4.24;

contract Betme
{
    address private _owner;
    uint private nonce;
    uint payForBet = 10000000000000000;

    struct BetParticipant {
        address _participantAddress;
        uint _participantAcceptBet;
        uint _participantAnswer;
    }

    struct PossibleAnswers {
        string _answer;
    }

    struct BetDetails {
        uint _timestamp;
        string _theBet;
        uint _numberOfPossibleAnswers;
        mapping(uint => PossibleAnswers) _posibleAnswers;
        uint _amount;
        address _betWitness;
        uint _numberOfParticipants;
        mapping(uint => BetParticipant) _betParticipants;
        uint _theWinner;
    }

    mapping(bytes32 => BetDetails) _bets;

    modifier validValue(uint amount) {
        require(msg.value == amount + payForBet);
        _;
    }

    modifier validParticipant(bytes32 betID, address addr, uint amount) {
        require(_bets[betID]._betParticipantOne == addr || _bets[betID]._betParticipantTwo == addr);
        require(msg.sender == _bets[betID]._betParticipantOne || msg.sender == _bets[betID]._betParticipantTwo);
        require(msg.value == amount);
        _;
    }

    modifier validWinner(address betWitness, bytes32 betID, uint wn) {
        require(_bets[betID]._betWitness == betWitness);
        require(_bets[betID]._theWinner == 0);
        require(_bets[betID]._betParticipantOneAcceptBet == 1);
        require(_bets[betID]._betParticipantTwoAcceptBet == 1);
        require(wn == 1 || wn == 2);
        _;
    }

    modifier validParticipants(bytes32 betID, address betParticipant){
        require(_bets[betID]._betWitness == betParticipant || _bets[betID]._betParticipantOne == betParticipant || _bets[betID]._betParticipantTwo == betParticipant);
        _;
    }

    constructor() public {
        _owner = msg.sender;
    }

    function() public payable {}

    function createBet(string theBet, uint amount, address betWitness, address betParticipantOne, address betParticipantTwo)
    public returns (bytes32 betID) {
        bytes32 unique = keccak256(abi.encodePacked(nonce++, theBet));
        _bets[unique] = BetDetails(block.timestamp, theBet, amount, betWitness, betParticipantOne, 0, betParticipantTwo, 0, 0);
        return (unique);
    }

    function acceptBet(bytes32 betID)
    validParticipant(betID, msg.sender, msg.value)
    validValue(msg.value)
    public payable {
        if (_bets[betID]._betParticipantOne == msg.sender) {
            _bets[betID]._betParticipantOneAcceptBet = 1;
            address(this).transfer(msg.value);
            _owner.transfer(payForBet);
        }
        else if (_bets[betID]._betParticipantTwo == msg.sender) {
            _bets[betID]._betParticipantTwoAcceptBet = 1;
            address(this).transfer(msg.value);
            _owner.transfer(payForBet);
        }
    }

    function getBet(bytes32 betID, address betParticipant)
    validParticipants(betID, betParticipant)
    public constant returns (
        uint timestamp,
        string theBet,
        uint amount,
        address betWitness,
        address betParticipantOne,
        address betParticipantTwo,
        uint theWinner
    ) {
        BetDetails memory betDetails = _bets[betID];
        return (
        betDetails._timestamp,
        betDetails._theBet,
        betDetails._amount,
        betDetails._betWitness,
        betDetails._betParticipantOne,
        betDetails._betParticipantTwo,
        betDetails._theWinner
        );
    }

    function setWinner(bytes32 betID, uint wn) validWinner(msg.sender, betID, wn) public {
        _bets[betID]._theWinner = wn;
        if (wn == 1) {
            _bets[betID]._betParticipantOne.transfer(_bets[betID]._amount);
        }
        else if (wn == 2) {
            _bets[betID]._betParticipantTwo.transfer(_bets[betID]._amount);
        }
    }

}
