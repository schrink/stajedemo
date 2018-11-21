<template>
    <div id="app">
        <section class="hero is-success is-bold">
            <div class="hero-body">
                <div class="container">
                    <h1 class="title">
                        Glasaj za restoran {{form.restaurant }}
                    </h1>
                    <h2 class="subtitle">
                        Solidity primer
                    </h2>
                </div>
            </div>
        </section>
        <section class="section">
            <el-form ref="form" :model="form" label-width="120px" @submit.native.prevent>
                <el-form-item label="Restoran">
                    <el-input placeholder="Predlozi restoran"
                              v-model="form.restaurant"></el-input>
                </el-form-item>
                <el-form-item>
                    <el-button type="primary" @click="onSubmit()">Startuj glasanje</el-button>
                </el-form-item>
            </el-form>
        </section>
        <section class="section" v-if="restaurant">
            <nav class="level">
                <div class="level-item has-text-centered">
                    <div>
                        <p class="heading">Vote date - {{proposalId | moment("from", "now")}}</p>
                        <p class="title">{{restaurant}}</p>
                    </div>
                </div>
                <div class="level-item has-text-centered">
                    <div>
                        <p class="heading">Created by</p>
                        <p class="title">{{proposalCreator}}</p>
                    </div>
                </div>
                <div class="level-item has-text-centered">
                    <div>
                        <p class="heading">YES</p>
                        <p class="title">{{votesYes}}</p>
                    </div>
                </div>
                <div class="level-item has-text-centered">
                    <div>
                        <p class="heading">NO</p>
                        <p class="title">{{votesNo}}</p>
                    </div>
                </div>
                <div class="level-item has-text-centered">
                    <div>
                        <p class="heading">Remaining time</p>
                        <p class="title">{{timeLeft}}</p>
                    </div>
                </div>
                <div class="level-item has-text-centered">
                    <div>
                        <p class="heading">Are we going?</p>
                        <p class="title">{{areWeGoing}}</p>
                    </div>
                </div>
            </nav>
            <el-row type="flex" justify="center">
                <el-radio-group v-model="voteYesNo" @change="sendVote" :disabled="voteYesNo">
                    <el-radio-button label="Yes"></el-radio-button>
                    <el-radio-button label="No"></el-radio-button>
                </el-radio-group>
            </el-row>
        </section>
        <section class="section">
            <h1 class="tile">Output</h1>
            <p class="control">{{output}}</p>
        </section>

    </div>

</template>

<script>
// const ganache = require('ganache-cli');
const Eth = require('ethjs');

export default {
  name: 'app',
  components: {},
  data() {
    return {
      form: {
        restaurant: '',
      },
      output: '',
      proposalId: '',
      proposalCreator: '',
      restaurant: '',
      votesNo: 0,
      votesYes: 0,
      timeLeft: 0,
      voteYesNo: false,
      myAccount: '',
      Contract: '',
    };
  },
  mounted() {
    const eth = new Eth(new Eth.HttpProvider('http://localhost:7545'));
    // if (typeof window.web3 !== 'undefined'
    // && typeof window.web3.currentProvider !== 'undefined') {
    //   eth.setProvider(window.web3.currentProvider);
    // } else {
    //   eth.setProvider(new Eth.HttpProvider('http://localhost:8545')); // set to TestRPC if not available
    // }
    const abi = [
      {
        constant: false,
        inputs: [
          {
            name: '_proposalId',
            type: 'uint256',
          },
        ],
        name: 'closeVoting',
        outputs: [],
        payable: false,
        stateMutability: 'nonpayable',
        type: 'function',
      },
      {
        constant: false,
        inputs: [
          {
            name: '_restaurant',
            type: 'string',
          },
          {
            name: '_votingDuration',
            type: 'uint256',
          },
          {
            name: '_proposalId',
            type: 'uint256',
          },
        ],
        name: 'createProposal',
        outputs: [],
        payable: false,
        stateMutability: 'nonpayable',
        type: 'function',
      },
      {
        constant: false,
        inputs: [
          {
            name: '_vote',
            type: 'bool',
          },
          {
            name: '_proposalId',
            type: 'uint256',
          },
        ],
        name: 'vote',
        outputs: [],
        payable: false,
        stateMutability: 'nonpayable',
        type: 'function',
      },
      {
        anonymous: false,
        inputs: [
          {
            indexed: false,
            name: 'proposalId',
            type: 'uint256',
          },
          {
            indexed: false,
            name: 'restaurant',
            type: 'string',
          },
          {
            indexed: false,
            name: 'votedYes',
            type: 'uint8',
          },
          {
            indexed: false,
            name: 'votedNo',
            type: 'uint8',
          },
        ],
        name: 'VotingResultEvent',
        type: 'event',
      },
      {
        constant: true,
        inputs: [
          {
            name: '',
            type: 'uint256',
          },
        ],
        name: 'proposals',
        outputs: [
          {
            name: 'proposalCreator',
            type: 'address',
          },
          {
            name: 'restaurant',
            type: 'string',
          },
          {
            name: 'votingStartTime',
            type: 'uint256',
          },
          {
            name: 'votingDuration',
            type: 'uint256',
          },
          {
            name: 'totalVotedYes',
            type: 'uint8',
          },
          {
            name: 'totalVotedNo',
            type: 'uint8',
          },
          {
            name: 'votingEnded',
            type: 'bool',
          },
        ],
        payable: false,
        stateMutability: 'view',
        type: 'function',
      },
    ];
    eth.accounts().then((accounts) => {
      // eslint-disable-next-line prefer-destructuring
      this.myAccount = accounts[0];
    });
    this.Contract = eth.contract(abi).at('0xa980325b8feaf207ccaebbf863b626c305e9104e');
  },
  computed: {
    areWeGoing() {
      const result = this.votesYes - this.votesNo;
      if (result === 0) return 'NOT DECIDED';
      return (result > 0) ? 'YES' : 'NO';
    },
  },
  methods: {
    sendVote() {
      const vote = (this.voteYesNo === 'Yes');
      this.Contract.vote(vote, this.proposalId, { from: this.myAccount, gas: 3000000 });
    },
    onSubmit() {
      const proposalId = Date.now();
      this.proposalId = proposalId;
      this.pollData(proposalId);
      this.Contract.createProposal(
        this.form.restaurant,
        300,
        proposalId,
        { from: this.myAccount, gas: 3000000 },
      ).then(() => {
        console.log(proposalId);
      }).catch((err) => {
        console.log(err);
      });
    },

    pollData(proposalId) {
      const votingInterval = setInterval(() => {
        this.Contract.proposals(proposalId).then((prop) => {
          this.votesYes = prop.totalVotedYes.toNumber();
          this.votesNo = prop.totalVotedNo.toNumber();
          this.restaurant = prop.restaurant;
          this.proposalCreator = `${prop.proposalCreator.substr(0, 12)}...`;
          this.timeLeft =
                    Math.round(prop.votingStartTime.toNumber()
                        + prop.votingDuration.toNumber() - ((new Date()).getTime() / 1000));
          if (this.timeLeft <= 0) {
            clearInterval(votingInterval);
          }
        });
      }, 1000);
    }
    ,
  },
};
</script>

<style lang="scss">

</style>
