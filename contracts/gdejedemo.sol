pragma solidity ^0.4.21;

contract GdeJedemo {

    struct Proposal {
        address proposalCreator;
        string restaurant; //prepraviti u bytes32
        uint256 votingStartTime;
        uint256 votingDuration;
        uint8 totalVotedYes;
        uint8 totalVotedNo;
        bool votingEnded;
    }


    mapping(uint256 => Proposal) public proposals;

    mapping(address => uint256) votedList;


    event VotingResultEvent(uint256 proposalId, string restaurant, uint8 votedYes, uint8 votedNo);


    function createProposal(string _restaurant, uint256 _votingDuration, uint256 _proposalId) {
        proposals[_proposalId].proposalCreator = msg.sender;
        proposals[_proposalId].restaurant = _restaurant;
        proposals[_proposalId].votingStartTime = now;
        proposals[_proposalId].votingDuration = _votingDuration;
    }

    function vote(bool _vote, uint256 _proposalId) {
        if(now > proposals[_proposalId].votingStartTime + proposals[_proposalId].votingDuration) {
            closeVoting(_proposalId); // da li da je automatski pozovemo ili da se poziva rucno? i da li ce se ovo uopste izvrsiti sa throw?
            throw; // mozda je bolje da se koristi require? nije mi potpuno jasna razlika
        }

        if(votedList[msg.sender] == _proposalId) {
            throw; // vec glasao
        }

        votedList[msg.sender] = _proposalId;

        if(_vote) { // dali postoji ternary?
            proposals[_proposalId].totalVotedYes += 1;
        } else {
            proposals[_proposalId].totalVotedNo += 1;
        }

    }

    function closeVoting(uint256 _proposalId) {
        if (now <= proposals[_proposalId].votingStartTime + proposals[_proposalId].votingDuration) {
            throw; // ne moze pre isteka vremena
        }

        if(proposals[_proposalId].votingEnded) {
            throw; //vec smo pozvali ovo
        }

        proposals[_proposalId].votingEnded = true;

        VotingResultEvent(_proposalId, proposals[_proposalId].restaurant, proposals[_proposalId].totalVotedYes, proposals[_proposalId].totalVotedNo);
    }
}