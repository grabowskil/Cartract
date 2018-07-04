# Cartract - An expandable SmartContract to check if you can start your car

This SmartContract was written for my master thesis and represents a car, which needs valid inspection and insurance to be started.

## Getting Started

### Prerequisites & Installing

To run and compile this contract yourself, you need to globally install the [truffle-framework!](https://github.com/trufflesuite/truffle):
```
$ npm install -g truffle
```

You will need to install a local ethereum RPC like testrpc, truffle develop or ganache. This contract was written against [ganache-cli!](https://github.com/trufflesuite/ganache-cli):
```
$ npm install -g ganache-cli
```

Just clone this git and use truffle and ganache to compile and test.

To run a migration ootb you will need to start ganache-cli with the following mnemonic:
```
misery ice toe feature hint family double royal quote buyer park gift
```

If you are using another RPC, you will need to adjust `truffle.js` accordingly.


## Running the tests

Run tests with truffle's integrated testsuite:
```
$ truffle test
```

Status, July 4, 2018:
test | result
---- | ------
should be only owner of car | [![test](https://img.shields.io/badge/test-passed-brightgreen.svg)]
shouldn't start engine | [![test](https://img.shields.io/badge/test-passed-brightgreen.svg)]
should administer authority | [![test](https://img.shields.io/badge/test-passed-brightgreen.svg)]
should apply new permits and start engine | [![test](https://img.shields.io/badge/test-passed-brightgreen.svg)]
should remove authority | [![test](https://img.shields.io/badge/test-passed-brightgreen.svg)]
should transfer owner | [![test](https://img.shields.io/badge/test-passed-brightgreen.svg)]

## Deployment

As this is just an academic starting point, there is currently no migration to a live network configured.

## Built With

* [truffle-framework!](https://github.com/trufflesuite/truffle)

## Authors

**Lennart Grabowski** - *Initial work* - [HunterXxX360](https://github.com/HunterXxX360)

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details

## Acknowledgments

This Code is heavily inspired by the CryptoKitties project: [awesome-cryptokitties](https://github.com/cryptocopycats/awesome-cryptokitties)
