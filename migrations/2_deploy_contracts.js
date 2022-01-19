const CookieFactory = artifacts.require('../contracts/token/cookiepang/CookieFactory.sol')
const fs = require('fs')

module.exports = function (_deployer) {
	// CookieFactory.deployed().then(function(instance) { cookieFactory = instance});

	_deployer.deploy(CookieFactory)
		.then(() => {
			if (CookieFactory._json) {
				fs.writeFile(
					'metadata/deployedABI',
					JSON.stringify(CookieFactory._json.abi, 2),
					(err) => {
						if (err) throw err
						console.log(`The abi of ${CookieFactory._json.contractName} is recorded on deployedABI file`)
					}
				)
			}

			fs.writeFile(
				'metadata/deployedAddress',
				CookieFactory.address,
				(err) => {
					if (err) throw err
					console.log(`The deployed contract address * ${CookieFactory.address} * is recorded on deployedAddress file`)
				}
			)
		});
};
