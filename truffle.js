/*
 * NB: since truffle-hdwallet-provider 0.0.5 you must wrap HDWallet providers in a
 * function when declaring them. Failure to do so will cause commands to hang. ex:
 * ```
 * mainnet: {
 *     provider: function() {
 *       return new HDWalletProvider(mnemonic, 'https://mainnet.infura.io/<infura-key>')
 *     },
 *     network_id: '1',
 *     gas: 4500000,
 *     gasPrice: 10000000000,
 *   },
 */

module.exports = {
  // See <http://truffleframework.com/docs/advanced/configuration>
  // to customize your Truffle configuration!
  networks: {
      development: {
          host: '127.0.0.1',
          port: 7545,
          network_id: '5777',
          // @dev mnemonic: misery ice toe feature hint family double royal quote buyer park gift
          from: '0x59228b8bf76ba4f272e00139a13839aa315d5479',
          gas: 6721975,
          gasPrice: 20000000000,
      }
  }
};
