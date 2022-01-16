pragma solidity ^0.5.6;

import "../KIP17/KIP17Full.sol";
import "../KIP17/KIP17Mintable.sol";
import "../KIP17/KIP17Burnable.sol";
import "../KIP17/KIP17Pausable.sol";

contract Cookie is KIP17Full("Fortune Cookie", "FC"), KIP17Mintable, KIP17Burnable, KIP17Pausable {

    event CookieCreated (uint256 indexed tokenId, string title, string text, string imageUrl, string tag);

    mapping(uint256 => CookieData) private _cookies;

    struct CookieData {
        uint256 tokenId;
        address[] ownerHistory;
        string title;
        string text;
        string imageUrl;
        string tag;
    }


    function tokenURI(uint256 tokenId) public view returns (string memory) {
        require(_exists(tokenId), "KIP17Metadata: URI query for non exist token");

        return "ipfs://QmNQ5MDtca32EW47ZSqBUQrpkBsiYnG1gjyoPXwUoVHYbo";
    }

    function createCookie(string memory _title, string memory _text, string memory _imageUrl, string memory _tag) public payable {
        uint256 _tokenId = totalSupply() + 1;

        _mint(msg.sender, _tokenId);

        address[] memory _ownerHistory;

        CookieData memory newCookie = CookieData(_tokenId, _ownerHistory, _title, _text, _imageUrl, _tag);

        _cookies[_tokenId] = newCookie;
        _cookies[_tokenId].ownerHistory.push(msg.sender);

        emit CookieCreated(_tokenId, _title, _text, _imageUrl, _tag);
    }

    function getFirstCreator(uint256 _tokenId) view public returns (address){
        return _cookies[_tokenId].ownerHistory[0];
    }
}