// SPDX-License-Identifier: MIT
// ERC721A Contracts v3.3.0
// Creators: Chiru Labs

pragma solidity ^0.8.4;
import { StartTokenIdHelperStorage } from "./StartTokenIdHelperStorage.sol";
import "../Initializable.sol";

/**
 * This Helper is used to return a dynmamic value in the overriden _startTokenId() function.
 * Extending this Helper before the ERC721A contract give us access to the herein set `startTokenId`
 * to be returned by the overriden `_startTokenId()` function of ERC721A in the ERC721AStartTokenId mocks.
 */
contract StartTokenIdHelperUpgradeable is Initializable {
    using StartTokenIdHelperStorage for StartTokenIdHelperStorage.Layout;

    function __StartTokenIdHelper_init(uint256 startTokenId_) internal onlyInitializing {
        __StartTokenIdHelper_init_unchained(startTokenId_);
    }

    function __StartTokenIdHelper_init_unchained(uint256 startTokenId_) internal onlyInitializing {
        StartTokenIdHelperStorage.layout().startTokenId = startTokenId_;
    }
    // generated getter for ${varDecl.name}
    function startTokenId() public view returns(uint256) {
        return StartTokenIdHelperStorage.layout().startTokenId;
    }

}
