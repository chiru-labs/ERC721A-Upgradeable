// SPDX-License-Identifier: MIT
// ERC721A Contracts v3.3.0
// Creators: Chiru Labs

pragma solidity ^0.8.4;

import "../extensions/ERC721AOwnersExplicitUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract ERC721AOwnersExplicitMockUpgradeable is Initializable, ERC721AOwnersExplicitUpgradeable {
    function __ERC721AOwnersExplicitMock_init(string memory name_, string memory symbol_) internal onlyInitializing {
        __ERC721A_init_unchained(name_, symbol_);
    }

    function __ERC721AOwnersExplicitMock_init_unchained(string memory, string memory) internal onlyInitializing {}

    function safeMint(address to, uint256 quantity) public {
        _safeMint(to, quantity);
    }

    function setOwnersExplicit(uint256 quantity) public {
        _setOwnersExplicit(quantity);
    }

    function getOwnershipAt(uint256 tokenId) public view returns (TokenOwnership memory) {
        return _ownerships[tokenId];
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}
