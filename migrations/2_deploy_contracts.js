var  kalpanaChawlaNFT = artifacts.require("TheUnexploredSpaceOfKalpanaChawla");
var operator = artifacts.require("Operator");

module.exports = async function (deployer) {
  const name = "kalpanachawala";
  const symbol = "KALPANACHAWLA";
  const baseURI = "https://gateway.pinata.cloud/ipfs/";
  await deployer.deploy(operator);
  const operatorObj = await operator.deployed();
  await deployer.deploy(kalpanaChawlaNFT, name, symbol, baseURI, operatorObj.address);
};
