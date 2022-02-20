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
    uint256 public mintingPriceForKlaytn;
    uint256 public mintingPriceForHammer;
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

    // Modifier
    modifier onlyCookieOwner(uint256 cookieId) {
        require(ownerOf(cookieId) == msg.sender, "NotCookieOwner");
        _;
    }

    // Event
    event CookieEvented(uint8 indexed eventStatus, uint256 indexed cookieId, address indexed from, uint256 hammerPrice, uint256 createdAt);

    // Function
    // NFT 거래에 사용할 KIP7 토큰 등록
    function setTradeCurrency(KIP7Token _tradeCurrency) onlyOwner external {
        tradeCurrency = _tradeCurrency;
    }

    // CoFounder 추가
    function addCoFounder(address payable cofounder) onlyOwner public {
        coFounderAddress.push(cofounder);
    }

    // 쿠키 발행에 필요한 klaytn 가격 등록
    function setMintingPriceForKlaytn(uint256 _mintingPriceForKlaytn) onlyOwner external {
        mintingPriceForKlaytn = _mintingPriceForKlaytn;
    }

    // 쿠키 발행에 필요한 Hammer 가격 등록
    function setMintingPriceForHammer(uint256 _mintingPriceForHammer) onlyOwner external {
        mintingPriceForHammer = _mintingPriceForHammer;
    }

    function getContent(uint256 cookieId) onlyCookieOwner(cookieId) public view returns (string memory) {
        return cookieInfos[cookieId].content;
    }

    function getCookieInfo(uint256 cookieId) public view returns (string memory title, string memory metaUrl, string memory tag, address creator, uint256 createdAt) {
        return (cookieInfos[cookieId].title, cookieInfos[cookieId].metaUrl, cookieInfos[cookieId].tag, cookieInfos[cookieId].creator, cookieInfos[cookieId].createdAt);
    }
    // 쿠키의 해머가격 변경
    function changeHammerPrice(uint256 _cookieId, uint256 _hammerPrice) onlyCookieOwner(_cookieId) public {
        cookieHammerPrices[_cookieId] = _hammerPrice;
        emit CookieEvented(uint8(EventStatus.MODIFY), _cookieId, msg.sender, _hammerPrice, now);
    }
    // 쿠키 숨기기
    function hideCookie(uint256 cookieId, bool isHide) onlyCookieOwner(cookieId) public {
        hideCookies[cookieId] = isHide;
    }

    // 쿠키 판매 등록
    function saleCookie(uint256 cookieId, bool isSale) onlyCookieOwner(cookieId) public {
        saleCookies[cookieId] = isSale;

        if(isSale) {
            approve(address(this), cookieId);
        }
    }

    // 쿠키 삭제
    function burnCookie(uint256 cookieId) onlyCookieOwner(cookieId) public {
        removeCookieInfo(cookieId);
        _burn(msg.sender, cookieId);
    }

    // 인출
    function withdraw() onlyOwner public {
        // TODO: 분배 로직 추가 필요
        coFounderAddress[0].transfer(address(this).balance);
    }

    function withdrawHammer() onlyOwner public {
        // TODO: 분배 로직 추가 필요
        uint256 totalHammerAmount = tradeCurrency.balanceOf(address(this));
        tradeCurrency.safeTransfer(coFounderAddress[0], totalHammerAmount);
    }

    // 쿠키 발행 (hammer)
    function mintCookieByHammer(string memory _title, string memory _content, string memory _metaUrl, string memory _tag, uint256 _hammerPrice) public returns (uint256) {
        require(tradeCurrency.balanceOf(msg.sender) >= mintingPriceForHammer, "Not Enough HammerCoin");
        if (mintingPriceForHammer > 0) {
            tradeCurrency.transferFrom(msg.sender, address(this), mintingPriceForHammer);
        }

        uint256 cookieId = createCookie(_title, _content, _metaUrl, _tag, _hammerPrice);
        return cookieId;
    }

    // 쿠키 발행 (klaytn)
    function mintCookieByKlaytn(string memory _title, string memory _content, string memory _metaUrl, string memory _tag, uint256 _hammerPrice) public payable returns (uint256) {
        require(msg.value >= mintingPriceForKlaytn, "Not Enough Klaytn");
        uint256 cookieId = createCookie(_title, _content, _metaUrl, _tag, _hammerPrice);
        return cookieId;
    }

    function mintCookieByOwner(address creator, string memory _title, string memory _content, string memory _metaUrl, string memory _tag, uint256 _hammerPrice) onlyOwner public returns (uint256) {
        uint256 cookieId = createCookie(_title, _content, _metaUrl, _tag, _hammerPrice);
        safeTransferFrom(msg.sender, creator, cookieId);
        return cookieId;
    }

    function createCookie(string memory _title, string memory _content, string memory _metaUrl, string memory _tag, uint256 _hammerPrice) internal returns (uint256) {
        uint256 _cookieId = getNewCookieId();
        super._mint(msg.sender, _cookieId);

        CookieInfo memory newCookie = CookieInfo(_cookieId, _title, _content, _metaUrl, _tag, msg.sender, now);
        cookieInfos[_cookieId] = newCookie;
        cookieHammerPrices[_cookieId] = _hammerPrice;

        // 민팅 이후 자동으로 판매 등록 및 거래 권한 위임
        saleCookies[_cookieId] = true;
        approve(address(this), _cookieId);

        emit CookieEvented(uint8(EventStatus.CREATE), _cookieId, msg.sender, _hammerPrice, now);
        return _cookieId;
    }

    // CoFounder 수익 분배 퍼센테이지
    function getSharePercentage() internal view returns (uint256) {
        require(coFounderAddress.length > 0, "there's no cofounder address");
        return SafeMath.div(100, coFounderAddress.length);
    }

    function buyCookie(uint256 _cookieId) public {
        require(saleCookies[_cookieId], "Cookie Not On Sale");
        uint256 _hammerPrice = cookieHammerPrices[_cookieId] * 1000000000000000000;
        require(tradeCurrency.balanceOf(msg.sender) >= _hammerPrice, "Not Enough Currency");
        address buyer = msg.sender;
        address seller = ownerOf(_cookieId);

        // this로 inner method 호출하는 이유는 msg.sender가 해당 컨트랙 주소로 변경되기 때문
        this.transferFrom(seller, buyer, _cookieId);
        tradeCurrency.transferFrom(buyer, seller, _hammerPrice);
        // 다시 해당 컨트랙에 전달
        approve(address(this), _cookieId);

        emit CookieEvented(uint8(EventStatus.BUY), _cookieId, msg.sender, _hammerPrice, now);
    }

    // 특정 cookieId 메타데이터 표기
    function tokenURI(uint256 cookieId) public view returns (string memory) {
        require(_exists(cookieId), "KIP17Metadata: URI query for non exist token");
        return cookieInfos[cookieId].metaUrl;
    }

    function getNewCookieId() internal returns (uint256) {
        lastCookieId = lastCookieId.add(1);
        return lastCookieId;
    }

    function removeCookieInfo(uint256 cookieId) onlyCookieOwner(cookieId) internal {
        delete cookieInfos[cookieId];
        delete cookieHammerPrices[cookieId];
        delete hideCookies[cookieId];
        delete saleCookies[cookieId];
    }

    function getOwnedCookieIds() public view returns (uint256[] memory) {
        return _tokensOfOwner(msg.sender);
    }
}
