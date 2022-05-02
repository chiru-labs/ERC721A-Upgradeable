// SPDX-License-Identifier: MIT
// ERC721A Contracts v3.3.0
// Creator: Chiru Labs

pragma solidity ^0.8.4;

import "./IERC721ABurnableUpgradeable.sol";
import "../ERC721AUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

/**
 * @title ERC721A Burnable Token
 * @dev ERC721A Token that can be irreversibly burned (destroyed).
 */
abstract contract ERC721ABurnableUpgradeable is Initializable, ERC721AUpgradeable, IERC721ABurnableUpgradeable {
    function __ERC721ABurnable_init() internal onlyInitializing {
    }

    function __ERC721ABurnable_init_unchained() internal onlyInitializing {
    }
    /**
     * @dev Burns `tokenId`. See {ERC721A-_burn}.
     *
     * Requirements:
     *
     * - The caller must own `tokenId` or be an approved operator.
     */
    function burn(uint256 tokenId) public virtual override {
        _burn(tokenId, true);
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}
