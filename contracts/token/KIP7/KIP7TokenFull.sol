pragma solidity ^0.5.0;

import "contracts/token/KIP7/KIP7Mintable.sol";
import "contracts/token/KIP7/KIP7Burnable.sol";
import "contracts/token/KIP7/KIP7Pausable.sol";
import "contracts/token/KIP7/KIP7Metadata.sol";
import "contracts/lifecycle/SelfDestructible.sol";
import "contracts/ownership/Ownable.sol";

contract KIP7TokenFull is KIP7Mintable, KIP7Burnable, KIP7Pausable, KIP7Metadata, Ownable, SelfDestructible {
    constructor(string memory name, string memory symbol, uint8 decimals, uint256 initialSupply) KIP7Metadata(name, symbol, decimals) public {
        _mint(msg.sender, initialSupply);
    }
}
