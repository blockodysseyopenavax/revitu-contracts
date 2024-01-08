// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721URIStorageUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@klaytn/contracts/KIP/token/KIP17/IKIP17Receiver.sol";

contract Revitu is
    Initializable,
    UUPSUpgradeable,
    ERC721Upgradeable,
    ERC721URIStorageUpgradeable,
    AccessControlUpgradeable
{
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");

    uint256 private _nextTokenId;
    string private baseTokenURI;

    mapping(uint256 => bool) lockMap;

    uint256[49] private __gap;

    modifier transferValidator(uint256 _tokenId) {
        require(lockMap[_tokenId], "this NFT is locked..");
        _;
    }

    function initialize(
        address _defaultAdmin,
        address _minter,
        string memory _baseURI
    ) public initializer {
        __ERC721_init("Blockodyssey Revitu NFT", "REVITU");
        __ERC721URIStorage_init();
        __AccessControl_init();
        __UUPSUpgradeable_init();

        _grantRole(DEFAULT_ADMIN_ROLE, _defaultAdmin);
        _grantRole(MINTER_ROLE, _minter);
        _grantRole(UPGRADER_ROLE, _defaultAdmin);
        baseTokenURI = _baseURI;
    }

    function _authorizeUpgrade(
        address newImplementation
    ) internal override onlyRole(UPGRADER_ROLE) {}

    function safeMint(
        address to,
        string memory uri,
        bool lockYn
    ) public onlyRole(MINTER_ROLE) {
        uint256 tokenId = _nextTokenId++;
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
        lockMap[tokenId] = lockYn;
    }

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

    function setLock(
        uint256 _tokenId,
        bool lockYn
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        lockMap[_tokenId] = lockYn;
    }

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override(ERC721Upgradeable, IERC721Upgradeable) {
        _transfer(from, to, tokenId);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override(ERC721Upgradeable, IERC721Upgradeable) {
        _safeTransfer(from, to, tokenId, "");
    }

    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override transferValidator(tokenId) {
        super._transfer(from, to, tokenId);
    }

    function _safeTransfer(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) internal virtual override transferValidator(tokenId) {
        super._transfer(from, to, tokenId);
        require(
            _checkOnKIP17Received(from, to, tokenId, data) ||
                _checkOnERC721Received2(from, to, tokenId, data),
            "ERC721: transfer to non ERC721Receiver implementer"
        );
    }

    function tokenURI(
        uint256 tokenId
    )
        public
        view
        override(ERC721Upgradeable, ERC721URIStorageUpgradeable)
        returns (string memory)
    {
        require(_exists(tokenId), "Token does not exist");

        string memory uri = baseTokenURI;
        return
            bytes(uri).length > 0
                ? string(abi.encodePacked(uri, super.tokenURI(tokenId)))
                : "";
    }

    function setBaseTokenUri(
        string memory _baseURI
    ) public onlyRole(MINTER_ROLE) {
        baseTokenURI = _baseURI;
    }

    function _burn(
        uint256 tokenId
    ) internal override(ERC721Upgradeable, ERC721URIStorageUpgradeable) {
        super._burn(tokenId);
    }

    function supportsInterface(
        bytes4 interfaceId
    )
        public
        view
        virtual
        override(
            ERC721Upgradeable,
            ERC721URIStorageUpgradeable,
            AccessControlUpgradeable
        )
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function _checkOnKIP17Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) private returns (bool) {
        if (to.code.length > 0) {
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

    function _checkOnERC721Received2(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) private returns (bool) {
        if (to.code.length > 0) {
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
}
