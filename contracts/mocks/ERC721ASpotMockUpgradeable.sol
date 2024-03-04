// SPDX-License-Identifier: MIT
// ERC721A Contracts v4.3.0
// Creators: Chiru Labs

pragma solidity ^0.8.4;

import './ERC721AQueryableMockUpgradeable.sol';
import './StartTokenIdHelperUpgradeable.sol';
import './SequentialUpToHelperUpgradeable.sol';
import '../ERC721A__Initializable.sol';

contract ERC721ASpotMockUpgradeable is
    ERC721A__Initializable,
    StartTokenIdHelperUpgradeable,
    SequentialUpToHelperUpgradeable,
    ERC721AQueryableMockUpgradeable
{
    function __ERC721ASpotMock_init(
        string memory name_,
        string memory symbol_,
        uint256 startTokenId_,
        uint256 sequentialUpTo_,
        uint256 quantity,
        bool mintInConstructor
    ) internal onlyInitializingERC721A {
        __StartTokenIdHelper_init_unchained(startTokenId_);
        __SequentialUpToHelper_init_unchained(sequentialUpTo_);
        __ERC721A_init_unchained(name_, symbol_);
        __ERC721AQueryable_init_unchained();
        __ERC721ABurnable_init_unchained();
        __DirectBurnBitSetterHelper_init_unchained();
        __ERC721AQueryableMock_init_unchained(name_, symbol_);
        __ERC721ASpotMock_init_unchained(name_, symbol_, startTokenId_, sequentialUpTo_, quantity, mintInConstructor);
    }

    function __ERC721ASpotMock_init_unchained(
        string memory,
        string memory,
        uint256,
        uint256,
        uint256 quantity,
        bool mintInConstructor
    ) internal onlyInitializingERC721A {
        if (mintInConstructor) {
            _mintERC2309(msg.sender, quantity);
        }
    }

    function _startTokenId() internal view override returns (uint256) {
        return startTokenId();
    }

    function _sequentialUpTo() internal view override returns (uint256) {
        return sequentialUpTo();
    }

    function exists(uint256 tokenId) public view returns (bool) {
        return _exists(tokenId);
    }

    function getOwnershipOf(uint256 index) public view returns (TokenOwnership memory) {
        return _ownershipOf(index);
    }

    function safeMintSpot(address to, uint256 tokenId) public {
        _safeMintSpot(to, tokenId);
    }

    function totalSpotMinted() public view returns (uint256) {
        return _totalSpotMinted();
    }

    function totalMinted() public view returns (uint256) {
        return _totalMinted();
    }

    function totalBurned() public view returns (uint256) {
        return _totalBurned();
    }

    function numberBurned(address owner) public view returns (uint256) {
        return _numberBurned(owner);
    }

    function setExtraDataAt(uint256 tokenId, uint24 value) public {
        _setExtraDataAt(tokenId, value);
    }

    function _extraData(
        address,
        address,
        uint24 previousExtraData
    ) internal view virtual override returns (uint24) {
        return previousExtraData;
    }
}
