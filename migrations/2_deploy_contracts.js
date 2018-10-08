var SimpleStorage = artifacts.require("./SimpleStorage.sol");
var Betme = artifacts.require("./Betme.sol");

module.exports = function (deployer) {
    deployer.deploy(SimpleStorage);
    deployer.deploy(Betme);
};
