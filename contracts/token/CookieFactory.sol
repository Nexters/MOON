pragma solidity ^0.5.0;

import "./KIP17/KIP17Full.sol";
import "./KIP17/KIP17Mintable.sol";
import "./KIP17/KIP17Burnable.sol";
import "./KIP17/KIP17Pausable.sol";
import "../ownership/Ownable.sol";
import {KIP7Token} from "./HammerCoin.sol";

contract CookieFactory is KIP17Full("CookiePang", "CKP"), Ownable {
    using SafeMath for uint256;

    // Data & Type
    KIP7Token private tradeCurrency;
    uint256 private lastCookieId;
    uint8 public mintingPriceForKlaytn;
    uint8 public mintingPriceForHammer;
    address payable[] public coFounderAddress;
    mapping(uint256 => CookieInfo) private cookieInfos;
    mapping(uint256 => uint256) public cookieHammerPrices;
    mapping(uint256 => bool) public hideCookies;
    mapping(uint256 => bool) public saleCookies;

    struct CookieInfo {
        uint256 cookieId;
        string title;
        string content;
        string metaUrl;
        string tag;
        address creator;
        uint256 createdAt;
    }
    enum EventStatus{
        CREATE,
        MODIFY,
        BUY
    }
    modifier onlyCookieOwner(uint256 cookieId) {
        require(ownerOf(cookieId) == msg.sender, "NotCookieOwner");
        _;
    }
    event CookieEvented(uint8 indexed eventStatus, uint256 indexed cookieId, address indexed from, uint256 hammerPrice, uint256 createdAt);

    // Function
    // NFT 거래에 사용할 KIP7 토큰 등록
    function setTradeCurrency(KIP7Token _tradeCurrency) onlyOwner external {
        tradeCurrency = _tradeCurrency;
    }
    function addCoFounder(address payable cofounder) onlyOwner public {
        coFounderAddress.push(cofounder);
    }
    function setMintingPriceForKlaytn(uint256 _mintingPriceForKlaytn) onlyOwner external {
        mintingPriceForKlaytn = _mintingPriceForKlaytn;
    }
    function setMintingPriceForHammer(uint256 _mintingPriceForHammer) onlyOwner external {
        mintingPriceForHammer = _mintingPriceForHammer;
    }
    function mintCookieByOwner(address creator, string memory _title, string memory _content, string memory _metaUrl, string memory _tag, uint256 _hammerPrice) onlyOwner public returns (uint256) {
        uint256 cookieId = createCookie(_title, _content, _metaUrl, _tag, _hammerPrice);
        safeTransferFrom(msg.sender, creator, cookieId);
        return cookieId;
    }
    function getContent(uint256 cookieId) onlyCookieOwner(cookieId) public view returns (string memory) {
        return cookieInfos[cookieId].content;
    }
    function getCookieInfo(uint256 cookieId) public view returns (string memory title, string memory metaUrl, string memory tag, address creator, uint256 createdAt) {
        return (cookieInfos[cookieId].title, cookieInfos[cookieId].metaUrl, cookieInfos[cookieId].tag, cookieInfos[cookieId].creator, cookieInfos[cookieId].createdAt);
    }
    function changeHammerPrice(uint256 _cookieId, uint256 _hammerPrice) onlyCookieOwner(_cookieId) public {
        cookieHammerPrices[_cookieId] = _hammerPrice;
        emit CookieEvented(uint8(EventStatus.MODIFY), _cookieId, msg.sender, _hammerPrice, now);
    }
    function hideCookie(uint256 cookieId, bool isHide) onlyCookieOwner(cookieId) public {
        hideCookies[cookieId] = isHide;
    }
    function saleCookie(uint256 cookieId, bool isSale) onlyCookieOwner(cookieId) public {
        saleCookies[cookieId] = isSale;
        if (isSale) {
            approve(address(this), cookieId);
        }
    }
    function burnCookie(uint256 cookieId) onlyCookieOwner(cookieId) public {
        removeCookieInfo(cookieId);
        _burn(msg.sender, cookieId);
    }

    function mintCookieByHammer(string memory _title, string memory _content, string memory _metaUrl, string memory _tag, uint256 _hammerPrice) public returns (uint256) {
        uint256 decimaledHammerPrice = mintingPriceForHammer * 1000000000000000000;
        require(tradeCurrency.balanceOf(msg.sender) >= decimaledHammerPrice, "Not Enough HammerCoin");
        if (mintingPriceForHammer > 0) {
            tradeCurrency.transferFrom(msg.sender, address(this), decimaledHammerPrice);
        }
        uint256 cookieId = createCookie(_title, _content, _metaUrl, _tag, _hammerPrice);
        return cookieId;
    }
    function mintCookieByKlaytn(string memory _title, string memory _content, string memory _metaUrl, string memory _tag, uint256 _hammerPrice) public payable returns (uint256) {
        uint256 decimaledKlaytnPrice = mintingPriceForKlaytn * 1000000000000000000;
        require(msg.value >= decimaledKlaytnPrice, "Not Enough Klaytn");
        uint256 cookieId = createCookie(_title, _content, _metaUrl, _tag, _hammerPrice);
        return cookieId;
    }
    function buyCookie(uint256 _cookieId) public {
        require(saleCookies[_cookieId], "Cookie Not On Sale");
        uint256 hammerPrice = cookieHammerPrices[_cookieId];
        uint256 decimaledHammerPrice = hammerPrice * 1000000000000000000;
        require(tradeCurrency.balanceOf(msg.sender) >= decimaledHammerPrice, "Not Enough Currency");
        address buyer = msg.sender;
        address seller = ownerOf(_cookieId);
        this.transferFrom(seller, buyer, _cookieId);

        tradeCurrency.safeTransferFrom(buyer, seller, decimaledHammerPrice);
        // 다시 해당 컨트랙에 전달
        approve(address(this), _cookieId);

        emit CookieEvented(uint8(EventStatus.BUY), _cookieId, msg.sender, hammerPrice, now);
    }
    function tokenURI(uint256 cookieId) public view returns (string memory) {
        require(_exists(cookieId), "KIP17Metadata: URI query for non exist token");
        return cookieInfos[cookieId].metaUrl;
    }
    function getOwnedCookieIds() public view returns (uint256[] memory) {
        return _tokensOfOwner(msg.sender);
    }
    function createCookie(string memory _title, string memory _content, string memory _metaUrl, string memory _tag, uint256 _hammerPrice) internal returns (uint256) {
        uint256 _cookieId = getNewCookieId();
        super._mint(msg.sender, _cookieId);
        CookieInfo memory newCookie = CookieInfo(_cookieId, _title, _content, _metaUrl, _tag, msg.sender, now);
        cookieInfos[_cookieId] = newCookie;
        cookieHammerPrices[_cookieId] = _hammerPrice;
        saleCookies[_cookieId] = true;
        approve(address(this), _cookieId);
        emit CookieEvented(uint8(EventStatus.CREATE), _cookieId, msg.sender, _hammerPrice, now);
        return _cookieId;
    }
    function removeCookieInfo(uint256 cookieId) onlyCookieOwner(cookieId) internal {
        delete cookieInfos[cookieId];
        delete cookieHammerPrices[cookieId];
        delete hideCookies[cookieId];
        delete saleCookies[cookieId];
    }
    function getSharePercentage() internal view returns (uint256) {
        require(coFounderAddress.length > 0, "there's no cofounder address");
        return SafeMath.div(100, coFounderAddress.length);
    }
    function getNewCookieId() internal returns (uint256) {
        lastCookieId = lastCookieId.add(1);
        return lastCookieId;
    }
}
