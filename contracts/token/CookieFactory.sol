pragma solidity ^0.5.0;

import "./KIP17/KIP17Full.sol";
import "./KIP17/KIP17Mintable.sol";
import "./KIP17/KIP17Burnable.sol";
import "./KIP17/KIP17Pausable.sol";
import "../ownership/Ownable.sol";
import {KIP7Token} from "./HammerCoin.sol";

contract CookieFactory is KIP17Full("CookiePang", "CKP"), Ownable {

    // Data & Type
    KIP7Token public tradeCurrency;
    uint256 public mintingPriceForKlaytn;
    uint256 public mintingPriceForHammer;
    address[] public coFounderAddress;
    mapping(uint256 => CookieInfo) public cookieInfos;
    mapping(uint256 => address) public cookieOwners;
    mapping(address => uint256)public ownedCookiesCount;
    mapping(uint256 => uint256) public cookieKlaytnPrices;
    mapping(uint256 => uint256) public cookieHammerPrices;
    mapping(uint256 => bool) public hideCookies;
    mapping(uint256 => bool) public saleCookies;

    struct CookieInfo {
        uint256 tokenId;
        string content;
        string text;
        string imageUrl;
        string tag;
    }

    // Modifier
    modifier onlyCookieOwner(uint256 tokenId) {
        require(ownerOf(tokenId) == msg.sender, "NotCookieOwner");
        _;
    }

    // Event
    event CookieCreated (address indexed from, uint256 indexed tokenId, string title, string content, string imageUrl, string tag, uint256 klaytnPrice, uint hammerPrice);
    event CookieTransacted (address indexed from, address indexed to, uint256 indexed tokenId);
    event CookieKlaytnPriceChanged(address indexed from, uint256 indexed tokenId, uint256 price);
    event CookieHammerPriceChanged(address indexed from, uint256 indexed tokenId, uint256 price);


    // Function

    // CoFounder 추가
    function addCoFounder(address cofounder) onlyOwner public {
        coFounderAddress.push(cofounder);
    }


    // NFT 거래에 사용할 KIP7 토큰 등록
    function setTradeCurrency(KIP7Token _trandeCurrency) onlyOwner external {
        tradeCurrency = _trandeCurrency;
    }

    // 쿠키 발행에 필요한 klaytn 가격 등록
    function setMintingPriceForKlaytn(uint256 _mintingPriceForKlaytn) onlyOwner external {
        mintingPriceForKlaytn = _mintingPriceForKlaytn;
    }

    // 쿠키 발행에 필요한 Hammer 가격 등록
    function setMintingPriceForHammer(uint256 _mintingPriceForHammer) onlyOwner external {
        mintingPriceForHammer = _mintingPriceForHammer;
    }

    // 쿠키 발행 (hammer)
    function mintCookieByHammer(string memory _title, string memory _content, string memory _imageUrl, string memory _tag, uint256 _klaytnPrice, uint256 _hammerPrice) public {
        // TODO: hammer contract로 transfer 및 require
        _mintCookie(_title, _content, _imageUrl, _tag, _klaytnPrice, _hammerPrice);
    }

    // 쿠키 발행 (klaytn)
    function mintCookieByKlaytn(string memory _title, string memory _content, string memory _imageUrl, string memory _tag, uint256 _klaytnPrice, uint256 _hammerPrice) public payable {
        require(msg.value > mintingPriceForKlaytn, "Klaytn이 모자랍니다");
        _mintCookie(_title, _content, _imageUrl, _tag, _klaytnPrice, _hammerPrice);
    }

    function mint(address to, uint256 tokenId) internal {
        super._mint(to, tokenId);
        cookieOwners[tokenId] = to;
        ownedCookiesCount[to]++;
    }

    function _mintCookie(string memory _title, string memory _content, string memory _imageUrl, string memory _tag, uint256 _klaytnPrice, uint256 _hammerPrice) internal {
        uint256 _tokenId = totalSupply() + 1;
        mint(msg.sender, _tokenId);
        CookieInfo memory newCookie = CookieInfo(_tokenId, _title, _content, _imageUrl, _tag);
        cookieInfos[_tokenId] = newCookie;
        cookieKlaytnPrices[_tokenId] = _klaytnPrice;
        cookieHammerPrices[_tokenId] = _hammerPrice;
        emit CookieCreated(msg.sender, _tokenId, _title, _content, _imageUrl, _tag, _klaytnPrice, _hammerPrice);
    }

    // 쿠키의 해머가격 변경
    function changeHammerPrice(uint256 tokenId, uint256 price) onlyCookieOwner(tokenId) public {
        cookieHammerPrices[tokenId] = price;
    }

    // 쿠키의 클레이튼 가격 변경
    function changeKlaytnPrice(uint256 tokenId, uint256 price) onlyCookieOwner(tokenId) public {
        cookieKlaytnPrices[tokenId] = price;
    }

    // 쿠키 숨기기
    function hideCookie(uint256 tokenId, bool isHide) onlyCookieOwner(tokenId) public {
        hideCookies[tokenId] = isHide;
    }

    // 쿠키 판매 등록
    function saleCookie(uint256 tokenId, bool isSale) onlyCookieOwner(tokenId) public {
        saleCookies[tokenId] = isSale;
    }

    // 쿠키 삭제
    function burnCookie(uint256 tokenId) onlyCookieOwner(tokenId) public {
        _burn(msg.sender, tokenId);
        // TODO: CookieFactory 컨트랙 내에 정보 삭제까지 포함

    }

    // TODO: internal로 변경 및 div 동작 확인(solidity 에는 분수개념이 없나?..) 및 withdraw
    function getShareRatio() public view returns (uint256) {
        require(coFounderAddress.length > 0, "there's no cofounder address");
        return SafeMath.div(1, coFounderAddress.length);
    }

    // 인출
    function withdraw() onlyOwner public {
        // do something...
    }

    function tokenURI(uint256 tokenId) public view returns (string memory) {
        require(_exists(tokenId), "KIP17Metadata: URI query for non exist token");
        // TODO: opensea에 resource 표기할때 사용되는 json파일  지금은 dummy (이후에 해당 부분은 Client <-> BE 결과로 생성된 리소스 전달하는방식으로)
    }

    // Override Function
    // TODO: TransferFrom & safeTransferFrom & Event emit
}