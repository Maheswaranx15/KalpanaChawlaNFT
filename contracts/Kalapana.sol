// SPDX-License-Identifier: UNLICENSED 
pragma solidity ^0.8.11;

import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./ERC2981.sol";

contract TheUnexploredSpaceOfKalpanaChawla is
  Context,
  ERC1155Burnable,
  ERC1155Supply,
  ERC2981,
  ReentrancyGuard
{
    using Counters for Counters.Counter;
    using Strings for uint256;
    Counters.Counter private _tokenIdTracker;
    mapping(uint256 => string) private _tokenURIs;
    string private baseTokenURI;
    string private _name;
    string private _symbol;
    address public operator;
    address public owner;
    address public uriEditor;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event OperatorChanged(address indexed previousOperator, address indexed newOperator);
    event URIEditorChanged(address indexed PreviousUriEditor, address indexed NewUriEditor);
    event RoyaltyUpdated(address indexed receiver, uint96 indexed fee);
    event URIUpadted(uint256 indexed tokenId, string indexed uri, string indexed newUri);
    event BaseURIChanged(string indexed uri, string indexed newuri);

    constructor(
        string memory _tokenName,
        string memory _tokenSymbol,
        string memory _baseTokenURI,
        address _operator
    ) ERC1155(_baseTokenURI) {
        operator = _operator;
        uriEditor = _msgSender();
        baseTokenURI = _baseTokenURI;
        owner = _msgSender();
        _name = _tokenName;
        _symbol = _tokenSymbol;
        _tokenIdTracker.increment();
        _setRoyalty(_msgSender(), 1000);

    }
    modifier onlyOwner() {
        require(owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    modifier onlyURIEditor() {
        require(uriEditor == msg.sender,"URIEditor: caller is not a Editor");
        _;
    }

    /** @dev change the Ownership from current owner to newOwner address
        @param newOwner : newOwner address */    

    function transferOwnership(address newOwner) public onlyOwner returns(bool) {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        return true;
    }

    function changeUriEditor(address newEditor) public onlyURIEditor returns(bool) {
        require(newEditor != address(0), "Editor: new Editor is the zero address");
        emit URIEditorChanged(uriEditor, newEditor);
        uriEditor = newEditor;
        return true;
    }

    function setBaseURI(string memory uri_) external onlyOwner returns(bool) {
        emit BaseURIChanged(baseTokenURI, uri_);
        baseTokenURI = uri_;
        return true;
    }

    function setOperator(address _operator) public onlyOwner returns(bool) {
        require(_operator != address(0), "Operator: operator is the Zero address");
        emit OperatorChanged(operator, _operator);
        operator = _operator;
        return true;
    }

    function mint(address creator, string memory _uri, uint256 supply) external nonReentrant returns(uint256 _tokenId){
        require(msg.sender == operator,"ERC1155: caller doesn't have operator Role");
        _tokenId = _tokenIdTracker.current();
        _setApprovalForAll(creator, operator, true);
        _mint(creator, _tokenId, supply, "");
        _tokenURIs[_tokenId] = _uri;
        _tokenIdTracker.increment();
        return _tokenId;
    }

    function setRoyaltyFee(address receiver, uint96 fee) external {
        require(msg.sender == operator,"ERC1155: caller doesn't have operator Role");
        _setRoyalty(receiver, fee);
        emit RoyaltyUpdated(receiver, fee);
    }

    function uri(uint256 tokenId) public view virtual override returns (string memory) {
        require(exists(tokenId), "ERC1155URIStorage: URI query for nonexistent token");

        string memory _tokenURI = _tokenURIs[tokenId];
        // If there is no base URI, return the token URI.
        if (bytes(baseTokenURI).length == 0) {
            return _tokenURI;
        }
        // If both are set, concatenate the baseURI and tokenURI (via abi.encodePacked).
        if (bytes(_tokenURI).length > 0) {
            return string(abi.encodePacked(baseTokenURI, _tokenURI));
        }
        return bytes(baseTokenURI).length > 0 ? string(abi.encodePacked(baseTokenURI, tokenId.toString())) : "";
    }

    function updateTokenURI(uint256 tokenId, string memory _uri) external onlyURIEditor returns(bool) {
        require(exists(tokenId), "ERC1155URIStorage: URI query for nonexistent token");
        emit URIUpadted(tokenId, _tokenURIs[tokenId], _uri);
        _tokenURIs[tokenId] = _uri;
        return true;
    }


    function name() external view returns (string memory) {
        return _name;
    }

    function symbol() external view returns (string memory) {
        return _symbol;
    }
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC2981, ERC1155)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function _beforeTokenTransfer(
        address _operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual override(ERC1155Supply, ERC1155) {
        super._beforeTokenTransfer(_operator, from, to, ids, amounts, data);
    }
}
