// SPDX-License-Identifier: MIT
// ERC721A Contracts v3.3.0
// Creators: Chiru Labs

pragma solidity ^0.8.4;
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

/**
 * This Helper is used to return a dynmamic value in the overriden _startTokenId() function.
 * Extending this Helper before the ERC721A contract give us access to the herein set `startTokenId`
 * to be returned by the overriden `_startTokenId()` function of ERC721A in the ERC721AStartTokenId mocks.
 */
contract StartTokenIdHelperUpgradeable is Initializable {
    uint256 public startTokenId;

    function __StartTokenIdHelper_init(uint256 startTokenId_) internal onlyInitializing {
        __StartTokenIdHelper_init_unchained(startTokenId_);
    }

    function __StartTokenIdHelper_init_unchained(uint256 startTokenId_) internal onlyInitializing {
        startTokenId = startTokenId_;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}
