pragma solidity ^0.5.0;

import "contracts/token/KIP7/KIP7Mintable.sol";
import "contracts/token/KIP7/KIP7Burnable.sol";
import "contracts/token/KIP7/KIP7Pausable.sol";
import "contracts/token/KIP7/KIP7Metadata.sol";

contract KIP7Token is KIP7Mintable, KIP7Burnable, KIP7Pausable, KIP7Metadata {
    constructor(string memory name, string memory symbol, uint8 decimals, uint256 initialSupply) KIP7Metadata(name, symbol, decimals) public {
        _mint(msg.sender, initialSupply);
    }
}