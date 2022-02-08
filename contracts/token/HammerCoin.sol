pragma solidity ^0.5.0;


import "../ownership/Ownable.sol";
import "./KIP7/KIP7Token.sol";

// HammerCoin 발행 컨트랙트. 해당 컨트랙 owner만 발행권 갖고있음.
// Spendable 상속받음으로써,'소비자' 의 Role을 갖고있는 address에 대해서만 spend 메소드 호출 가능
contract HammerCoin is KIP7Token("HammerCoin", "HMC", 18, 10000000000000000000000) {

}