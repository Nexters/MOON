pragma solidity >=0.5.0;

import "contracts/token/KIP17/KIP17Full.sol";
import "contracts/token/KIP17/KIP17MetadataMintable.sol";
import "contracts/token/KIP17/KIP17Mintable.sol";
import "contracts/token/KIP17/KIP17Burnable.sol";
import "contracts/token/KIP17/KIP17Pausable.sol";

contract KIP17Token is KIP17Full, KIP17Mintable, KIP17MetadataMintable, KIP17Burnable, KIP17Pausable {
    constructor (string memory name, string memory symbol) public KIP17Full(name, symbol) {
    }
}