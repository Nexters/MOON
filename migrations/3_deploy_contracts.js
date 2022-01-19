const HammerCoin = artifacts.require('../contracts/token/cookiepang/HammerCoin.sol')
const fs = require('fs')

module.exports = function (_deployer) {

	// truffle console 에서 아래 순서로 시나리오 진행해볼수있음..
	// abi = {abi}
	// addr = {coinAddress}
	// CookieFactory.deployed().then(function(instance) { cookieFactory = instance});
	// HammerCoin.deployed().then(function(instance) { coin = instance});
	// cookieFactory.setMintingCurrency(addr)
	// cookieFactory.setMintingPrice(300000)
	// web3.eth.getAccounts()
	// account1 = ... (여기서 ganache 계정일경우 대문자 바뀌어서 들어가므로 receipt에 나오는 from 주소로 ..)
	// web3.eth.getAccounts().then(function(res){ return web3.eth.getBalance(res[0]).then(function(res2){ return web3.utils.fromWei(res2, 'ether')})})
	// coin.mint(account1, 30000)
	// contract.methods.balanceOf(account1).call()
	// cookieFactory.createCookieByHammer


	_deployer.deploy(HammerCoin)
		.then(() => {
			if (HammerCoin._json) {
				fs.writeFile(
					'metadata/KIP7deployedABI',
					JSON.stringify(HammerCoin._json.abi, 2),
					(err) => {
						if (err) throw err
						console.log(`The abi of ${HammerCoin._json.contractName} is recorded on deployedABI file`)
					}
				)
			}

			fs.writeFile(
				'metadata/KIP7deployedAddress',
				HammerCoin.address,
				(err) => {
					if (err) throw err
					console.log(`The deployed contract address * ${HammerCoin.address} * is recorded on deployedAddress file`)
				}
			)
		});
};
