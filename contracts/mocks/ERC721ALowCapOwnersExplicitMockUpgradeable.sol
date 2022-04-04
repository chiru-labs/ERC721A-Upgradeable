// SPDX-License-Identifier: MIT
// Creators: Chiru Labs

pragma solidity ^0.8.4;

import "./ERC721ALowCapMockUpgradeable.sol";
import "../extensions/ERC721AOwnersExplicitUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract ERC721ALowCapOwnersExplicitMockUpgradeable is Initializable, ERC721ALowCapMockUpgradeable, ERC721AOwnersExplicitUpgradeable {
    function __ERC721ALowCapOwnersExplicitMock_init(string memory name_, string memory symbol_) internal onlyInitializing {
        __ERC721A_init_unchained(name_, symbol_);
        __ERC721ALowCapMock_init_unchained(name_, symbol_);
    }

    function __ERC721ALowCapOwnersExplicitMock_init_unchained(string memory, string memory) internal onlyInitializing {}

    function setOwnersExplicit(uint256 quantity) public {
        _setOwnersExplicit(quantity);
    }

    function getOwnershipAt(uint256 index) public view returns (TokenOwnership memory) {
        return _ownerships[index];
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}
