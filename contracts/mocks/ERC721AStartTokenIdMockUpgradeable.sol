// SPDX-License-Identifier: MIT
// ERC721A Contracts v3.3.0
// Creators: Chiru Labs

pragma solidity ^0.8.4;

import "./ERC721AMockUpgradeable.sol";
import "./StartTokenIdHelperUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract ERC721AStartTokenIdMockUpgradeable is Initializable, StartTokenIdHelperUpgradeable, ERC721AMockUpgradeable {
    function __ERC721AStartTokenIdMock_init(
        string memory name_,
        string memory symbol_,
        uint256 startTokenId_
    ) internal onlyInitializing {
        __StartTokenIdHelper_init_unchained(startTokenId_);
        __ERC721A_init_unchained(name_, symbol_);
        __ERC721AMock_init_unchained(name_, symbol_);
    }

    function __ERC721AStartTokenIdMock_init_unchained(
        string memory,
        string memory,
        uint256
    ) internal onlyInitializing {}

    function _startTokenId() internal view override returns (uint256) {
        return startTokenId;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}
