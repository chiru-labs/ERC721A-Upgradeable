// SPDX-License-Identifier: MIT
// ERC721A Contracts v3.3.0
// Creators: Chiru Labs

pragma solidity ^0.8.4;

import "./ERC721AOwnersExplicitMockUpgradeable.sol";
import "./StartTokenIdHelperUpgradeable.sol";
import { StartTokenIdHelperStorage } from "./StartTokenIdHelperStorage.sol";
import "../Initializable.sol";

contract ERC721AOwnersExplicitStartTokenIdMockUpgradeable is Initializable, StartTokenIdHelperUpgradeable, ERC721AOwnersExplicitMockUpgradeable {
    using StartTokenIdHelperStorage for StartTokenIdHelperStorage.Layout;
    function __ERC721AOwnersExplicitStartTokenIdMock_init(
        string memory name_,
        string memory symbol_,
        uint256 startTokenId_
    ) internal onlyInitializing {
        __StartTokenIdHelper_init_unchained(startTokenId_);
        __ERC721A_init_unchained(name_, symbol_);
        __ERC721AOwnersExplicit_init_unchained();
        __ERC721AOwnersExplicitMock_init_unchained(name_, symbol_);
        __ERC721AOwnersExplicitStartTokenIdMock_init_unchained(name_, symbol_, startTokenId_);
    }

    function __ERC721AOwnersExplicitStartTokenIdMock_init_unchained(
        string memory,
        string memory,
        uint256
    ) internal onlyInitializing {}

    function _startTokenId() internal view override returns (uint256) {
        return StartTokenIdHelperStorage.layout().startTokenId;
    }
}
