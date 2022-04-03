// SPDX-License-Identifier: MIT
// Creator: Chiru Labs

pragma solidity ^0.8.4;

import "../ERC721AUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

error ContractPaused();

/**
 * @dev ERC721A token with pausable token transfers, minting and burning.
 *
 * Based off of OpenZeppelin's ERC721Pausable extension.
 *
 * Useful for scenarios such as preventing trades until the end of an evaluation
 * period, or having an emergency switch for freezing all token transfers in the
 * event of a large bug.
 */
abstract contract ERC721APausableUpgradeable is Initializable, ERC721AUpgradeable, PausableUpgradeable {
    function __ERC721APausable_init() internal onlyInitializing {
        __Pausable_init_unchained();
    }

    function __ERC721APausable_init_unchained() internal onlyInitializing {
    }
    /**
     * @dev See {ERC721A-_beforeTokenTransfers}.
     *
     * Requirements:
     *
     * - the contract must not be paused.
     */
    function _beforeTokenTransfers(
        address from,
        address to,
        uint256 startTokenId,
        uint256 quantity
    ) internal virtual override {
        super._beforeTokenTransfers(from, to, startTokenId, quantity);
        if (paused()) revert ContractPaused();
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}
