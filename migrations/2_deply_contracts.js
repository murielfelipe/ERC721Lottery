const LotteryNFT = artifacts.require("LotteryNFT");

module.exports = function(deployer) {
  deployer.deploy(LotteryNFT);
}
