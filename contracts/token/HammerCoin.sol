pragma solidity ^0.5.6;

import "contracts/access/Roles.sol";
import "contracts/token/KIP7/KIP7Token.sol";
import "contracts/ownership/Ownable.sol";

contract SpenderRole {
    using Roles for Roles.Role;

    event SpenderAdded(address indexed account);
    event SpenderRemoved(address indexed account);

    Roles.Role private spenders;

    constructor() internal {
        _addSpender(msg.sender);
    }

    modifier onlySpender() {
        require(isSpender(msg.sender));
        _;
    }

    function isSpender(address account) public view returns (bool) {
        return spenders.has(account);
    }

    function addSpender(address account) public onlySpender {
        _addSpender(account);
    }

    function renounceSpender() public {
        _removeSpender(msg.sender);
    }

    function _addSpender(address account) internal {
        spenders.add(account);
        emit SpenderAdded(account);
    }

    function _removeSpender(address account) internal {
        spenders.remove(account);
        emit SpenderRemoved(account);
    }
}

contract KIP7Spendable is KIP7Token, SpenderRole {

    function spend(address from, uint256 value) public returns (bool) {
        // TODO: Hammer 회수하는 컨트랙으로 전송
        _burn(from, value);
        return true;
    }
}


// HammerCoin 발행 컨트랙트. 해당 컨트랙 owner만 발행권 갖고있음.
// Spendable 상속받음으로써,'소비자' 의 Role을 갖고있는 address에 대해서만 spend 메소드 호출 가능
contract HammerCoin is KIP7Token("HammerCoin", "HMC", 18, 0), KIP7Spendable, Ownable {
    function mint(address to, uint256 value) public onlyOwner returns (bool) {
        _mint(to, value);
        return true;
    }
}