const ChimpDao = artifacts.require("ChimpDAO");
const ChimpAuction = artifacts.require("ChimpAuction");

const CHIMPStakingReserve = artifacts.require("CHIMPStakingReserve");
const CHIMPMasterChef = artifacts.require("CHIMPMasterChef");

const TestToken = artifacts.require("TestToken");
const ChimpPublicSale = artifacts.require("ChimpPublicSale");
const Web3 = require("web3");

const price = Web3.utils.toWei("0.001");
const maxBuyLimit = Web3.utils.toWei("10000");

const chimpPerBlock = Web3.utils.toWei("0.1");

module.exports = async function (deployer) {
  // await deployer.deploy(TestToken);

  // const TEST_TOKEN_ADDRESS = TestToken.address;

  await deployer.deploy(ChimpDao);
  const CHIMP_ADDRESS = ChimpDao.address;
  await deployer.deploy(ChimpAuction);
  await deployer.deploy(ChimpPublicSale,CHIMP_ADDRESS,price,maxBuyLimit);
  const chimpInstnce = await ChimpDao.deployed();
  await chimpInstnce.transfer(ChimpPublicSale.address,Web3.utils.toWei("1000000"));
  await deployer.deploy(CHIMPStakingReserve, CHIMP_ADDRESS);
  await chimpInstnce.transfer(CHIMPStakingReserve.address,Web3.utils.toWei("10000000"));

  const CHIMPStakingReserveinstance = await CHIMPStakingReserve.deployed();
  await deployer.deploy(
    CHIMPMasterChef,
    CHIMP_ADDRESS,
    "0x0e601eEBc95747eb4132EE5250c33a1f78F58Eb6",
    chimpPerBlock,
    CHIMPStakingReserve.address,
    22101373
  );
  await CHIMPStakingReserveinstance.addOrRemoveOperators(CHIMPMasterChef.address,true);
  const CHIMPMasterChefInstance  = await CHIMPMasterChef.deployed();
  await CHIMPMasterChefInstance.add(1000,CHIMP_ADDRESS,0,false);


  const ChimpAuctioninstance  = await ChimpAuction.deployed();
  await ChimpAuctioninstance.flipAuctionState();
  await ChimpAuctioninstance.setMinBidAmount(Web3.utils.toWei("0.001"));

    const ChimpPublicSaleInstance  = await ChimpPublicSale.deployed() 
    await ChimpPublicSaleInstance.flipDepositState();
  // isDepositEnabled
  await ChimpPublicSaleInstance.setWhiteListRoot("0x85af778c708664551d3ecf2ab8286d58a087ca5f8f0a02cccc6ff05d89e7a048")

};
