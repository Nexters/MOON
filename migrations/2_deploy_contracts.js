const Cookie = artifacts.require('../contracts/token/cookiepang/Cookie.sol')
const fs = require('fs')

module.exports = function (_deployer) {

	_deployer.deploy(Cookie)
		.then(() => {
			if (Cookie._json) {
				fs.writeFile(
					'deployedABI',
					JSON.stringify(Cookie._json.abi, 2),
					(err) => {
						if (err) throw err
						console.log(`The abi of ${Cookie._json.contractName} is recorded on deployedABI file`)
					}
				)
			}

			fs.writeFile(
				'deployedAddress',
				Cookie.address,
				(err) => {
					if (err) throw err
					console.log(`The deployed contract address * ${Cookie.address} * is recorded on deployedAddress file`)
				}
			)
		})
};
