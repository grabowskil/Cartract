var car = artifacts.require("./carCore.sol");

module.exports = function(deployer) {
  deployer.deploy(car);
};
