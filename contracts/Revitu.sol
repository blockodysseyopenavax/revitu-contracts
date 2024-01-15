// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.18;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721EnumerableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721URIStorageUpgradeable.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@klaytn/contracts/KIP/token/KIP17/IKIP17Receiver.sol";

contract Revitu is
    Initializable,
    UUPSUpgradeable,
    AccessControlUpgradeable,
    ERC721EnumerableUpgradeable,
    ERC721URIStorageUpgradeable
{
    using Address for address;

    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    uint256 private _nextTokenId;
    string private _baseTokenURI;
    mapping(uint256 => bool) private _isLocked;

    uint256[47] private __gap;

    function initialize(
        address defaultAdmin,
        address minter,
        address upgrader,
        string memory baseTokenURI
    ) public initializer {
        __UUPSUpgradeable_init();
        __AccessControl_init();
        __ERC721_init("Blockodyssey Revitu NFT", "REVITU");
        __ERC721Enumerable_init();
        __ERC721URIStorage_init();

        _baseTokenURI = baseTokenURI;

        _grantRole(DEFAULT_ADMIN_ROLE, defaultAdmin);
        _grantRole(MINTER_ROLE, minter);
        _grantRole(UPGRADER_ROLE, upgrader);
    }

    function safeMint(
        address to,
        string memory uri
    ) public onlyRole(MINTER_ROLE) {
        uint256 tokenId = _nextTokenId++;
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
    }

    function setBaseTokenURI(
        string memory baseTokenURI
    ) public virtual onlyRole(DEFAULT_ADMIN_ROLE) {
        _baseTokenURI = baseTokenURI;
    }

    function lockToken(uint256 tokenId) public onlyRole(DEFAULT_ADMIN_ROLE) {
        _requireMinted(tokenId);
        if (!_isLocked[tokenId]) _isLocked[tokenId] = true;
    }

    function unlockToken(uint256 tokenId) public onlyRole(DEFAULT_ADMIN_ROLE) {
        _requireMinted(tokenId);
        if (_isLocked[tokenId]) _isLocked[tokenId] = false;
    }

    function isLocked(uint256 tokenId) public view virtual returns (bool) {
        _requireMinted(tokenId);
        return _isLocked[tokenId];
    }

    function supportsInterface(
        bytes4 interfaceId
    )
        public
        view
        virtual
        override(
            AccessControlUpgradeable,
            ERC721EnumerableUpgradeable,
            ERC721URIStorageUpgradeable
        )
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function tokenURI(
        uint256 tokenId
    )
        public
        view
        virtual
        override(ERC721Upgradeable, ERC721URIStorageUpgradeable)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function getBaseTokenURI() public view virtual returns (string memory) {
        return _baseTokenURI;
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 firstTokenId,
        uint256 batchSize
    )
        internal
        virtual
        override(ERC721Upgradeable, ERC721EnumerableUpgradeable)
    {
        for (
            uint256 tokenId = firstTokenId;
            tokenId < firstTokenId + batchSize;
            tokenId++
        ) {
            require(
                !_isLocked[tokenId],
                "Revitu: locked token cannot be moved"
            );
        }

        super._beforeTokenTransfer(from, to, firstTokenId, batchSize);
    }

    // same function with KIP17._safeTransfer()
    function _safeTransfer(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual override {
        _transfer(from, to, tokenId);
        require(
            _checkOnKIP17Received(from, to, tokenId, _data) ||
                _checkOnERC721Received2(from, to, tokenId, _data),
            "KIP17: transfer to non IKIP17Receiver/IERC721Receiver implementer"
        );
    }

    // same function with KIP17._safeMint()
    function _safeMint(
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual override {
        _mint(to, tokenId);
        require(
            _checkOnKIP17Received(address(0), to, tokenId, _data) ||
                _checkOnERC721Received2(address(0), to, tokenId, _data),
            "KIP17: transfer to non IKIP17Receiver/IERC721Receiver implementer"
        );
    }

    function _burn(
        uint256 tokenId
    )
        internal
        virtual
        override(ERC721Upgradeable, ERC721URIStorageUpgradeable)
    {
        super._burn(tokenId);
    }

    function _authorizeUpgrade(
        address newImplementation
    ) internal virtual override onlyRole(UPGRADER_ROLE) {}

    function _baseURI() internal view virtual override returns (string memory) {
        return _baseTokenURI;
    }

    // same function with KIP17._checkOnKIP17Received()
    function _checkOnKIP17Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) private returns (bool) {
        if (to.isContract()) {
            try
                IKIP17Receiver(to).onKIP17Received(
                    _msgSender(),
                    from,
                    tokenId,
                    _data
                )
            returns (bytes4 retval) {
                return retval == IKIP17Receiver.onKIP17Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    return false;
                } else {
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }

    // same function with ERC721._checkOnERC721Received()
    // workaround for private non-virtual function ERC721._checkOnERC721Received()
    function _checkOnERC721Received2(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) private returns (bool) {
        if (to.isContract()) {
            try
                IERC721ReceiverUpgradeable(to).onERC721Received(
                    _msgSender(),
                    from,
                    tokenId,
                    data
                )
            returns (bytes4 retval) {
                return
                    retval ==
                    IERC721ReceiverUpgradeable.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert(
                        "ERC721: transfer to non ERC721Receiver implementer"
                    );
                } else {
                    /// @solidity memory-safe-assembly
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }

    /**
     * @dev Disable implementation's initializer.
     * See https://docs.openzeppelin.com/upgrades-plugins/1.x/writing-upgradeable#initializing_the_implementation_contract
     */
    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }
}
