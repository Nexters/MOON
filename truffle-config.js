const HDWalletProvider = require("truffle-hdwallet-provider-klaytn");

// module.exports = 'baobab private key' 로 되어있는 key.js 파일 필요
const PRIVATE_KEY = require("./key.js");
const BAOBAB_TEST_NODE = "https://api.baobab.klaytn.net:8651";

module.exports = {
  networks: {
    dev: {
     host: "localhost",     // Localhost (default: none)
     port: 8545,            // Standard Ethereum port (default: none)
     network_id: "*",       // Any network (default: none)
    },
    baobab: {
      provider: () => {
        return new HDWalletProvider(PRIVATE_KEY, BAOBAB_TEST_NODE);
      },
      network_id: "1001",
      gas: "8500000",
      gasPrice: null,
    }
  },
  plugins: [
    'truffle-contract-size'
  ],
  // Set default mocha options here, use special reporters etc.
  mocha: {
    // timeout: 100000
  },

  // Configure your compilers
  compilers: {
    solc: {
      version: "0.5.6",
    }
  },
};
