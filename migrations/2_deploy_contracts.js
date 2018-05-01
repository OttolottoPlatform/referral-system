var ReferralSystem = artifacts.require("./ReferralSystem.sol");

module.exports = function(deployer) {
  deployer.deploy(ReferralSystem, {gas:500000});
};
