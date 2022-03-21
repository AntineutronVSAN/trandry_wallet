const TestLotery = artifacts.require("TestLotery");
const FlutterLotery = artifacts.require("FlutterLotery");

module.exports = function (deployer) {
  deployer.deploy(TestLotery);
  deployer.deploy(FlutterLotery);
};