pragma solidity ^0.5.0;


import "../ownership/Ownable.sol";
import "./KIP7/KIP7Token.sol";
import "../ownership/Ownable.sol";

// HammerCoin 발행 컨트랙트. 해당 컨트랙 owner만 발행권 갖고있음.
contract HammerCoin is KIP7Token, Ownable {

    uint256 constant private MAX_INT_HEX = 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;
    address private cookieContractAddress;

    constructor(string memory name, string memory symbol, uint8 decimals, uint256 initialSupply) KIP7Token(name, symbol, decimals, initialSupply) public {
        _mint(msg.sender, initialSupply);
    }

    mapping(address => bool) public maxApprovedAddress;

    function maxApprove() public {
        approve(cookieContractAddress, MAX_INT_HEX);
        maxApprovedAddress[msg.sender] = true;
    }

    function setCookieContractAddress(address _cookieContractAddress) public onlyOwner {
        cookieContractAddress = _cookieContractAddress;
    }
}