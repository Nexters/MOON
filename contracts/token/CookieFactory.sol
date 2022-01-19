pragma solidity ^0.5.6;

import "contracts/token/KIP17/KIP17Full.sol";
import "contracts/token/KIP17/KIP17Mintable.sol";
import "contracts/token/KIP17/KIP17Burnable.sol";
import "contracts/token/KIP17/KIP17Pausable.sol";
import "contracts/ownership/Ownable.sol";
import {KIP7Spendable} from "contracts/token/HammerCoin.sol";

contract CookieFactory is KIP17Full("Fortune Cookie", "FC"), KIP17Mintable, KIP17Burnable, KIP17Pausable, Ownable {

    // klaytn 민팅 가격
    uint256 _mintingPrice;

    // 망치 민팅 가격
    KIP7Spendable _mintingCurrency;

    mapping(uint256 => bytes32) certificateDataHashes;

    event CookieCreated (uint256 indexed tokenId, string title, string text, string imageUrl, string tag);

    mapping(uint256 => CookieInfo) private _cookies;

    // withdraw addresses
    address t1 = 0xe3F744017BB487F88B1CE9587FfD672E9F306769;
    address t2 = 0x563262776d630b240A7384ce0dE4c05eC0f50bA3;
    // 이 주소 왜 안돼지?;;
//    address t3 = 0xaa52e03e26eaca72fd22137fb72f12b0189da23a;
    address t4 = 0xD7D7360e176BD97a37a32cA7723cAeBC8Dc9Ee1F;
    address t5 = 0xF2028A9aefc6d079Ef91D179C544a060b5E2d9De;
    address t6 = 0x2fda7dfD31D1f5fD6986eb000823d65bf4235cbf;
    address t7 = 0x3A3Ab1B9B31772C25e63085B2c54c068492e933F;
    address t8 = 0x0827B0Fa3f9a804220C7Dfd0774A753580cC3160;

    struct CookieInfo {
        uint256 tokenId;
        string title;
        string text;
        string imageUrl;
        string tag;
    }

    function hashForToken(uint256 tokenId) external view returns (bytes32) {
        return certificateDataHashes[tokenId];
    }

    function mintingPrice() external view returns (uint256) {
        return _mintingPrice;
    }

    function mintingCurrency() external view returns (KIP7Spendable) {
        return _mintingCurrency;
    }

    function setMintingPrice(uint256 newMintingPrice) onlyOwner external {
        _mintingPrice = newMintingPrice;
    }

    function setMintingCurrency(KIP7Spendable newMintingCurrency) onlyOwner external {
        _mintingCurrency = newMintingCurrency;
    }

    function createCookieByHammer(string memory _title, string memory _text, string memory _imageUrl, string memory _tag) public {
        // 문제지점
        _mintingCurrency.spend(msg.sender, _mintingPrice);

        _createCookie(_title, _text, _imageUrl, _tag);
    }

    // Cookie = NFT
    function createCookie(string memory _title, string memory _text, string memory _imageUrl, string memory _tag) public payable {
        require(msg.value > _mintingPrice, "Klaytn이 모자랍니다");
        _createCookie(_title, _text, _imageUrl, _tag);
    }

    function _createCookie(string memory _title, string memory _text, string memory _imageUrl, string memory _tag) internal {
        uint256 _tokenId = totalSupply() + 1;

        _mint(msg.sender, _tokenId);
        CookieInfo memory newCookie = CookieInfo(_tokenId, _title, _text, _imageUrl, _tag);

        _cookies[_tokenId] = newCookie;

        emit CookieCreated(_tokenId, _title, _text, _imageUrl, _tag);
    }

    function tokenURI(uint256 tokenId) public view returns (string memory) {
        require(_exists(tokenId), "KIP17Metadata: URI query for non exist token");
        // 지금은 dummy (이후에 해당 부분은 Client <-> BE 결과로 생성된 리소스 전달해줘야할것으로 예상됨)
        return "ipfs://QmNQ5MDtca32EW47ZSqBUQrpkBsiYnG1gjyoPXwUoVHYbo";
    }

}