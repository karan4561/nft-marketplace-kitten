const token = artifacts.require("kittycontract");

module.exports = function (deployer) {
  deployer.deploy(token);
};
