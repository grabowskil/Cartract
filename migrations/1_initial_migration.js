var car = artifacts.require("./CarCore.sol");

module.exports = function(deployer) {
  deployer.deploy(car);
};
