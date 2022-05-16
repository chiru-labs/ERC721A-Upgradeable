// SPDX-License-Identifier: MIT
// ERC721A Contracts v3.3.0
// Creator: Chiru Labs

pragma solidity ^0.8.4;

import "../ERC721AUpgradeable.sol";
import { ERC721AOwnersExplicitStorage } from "./ERC721AOwnersExplicitStorage.sol";
import { ERC721AStorage } from "../ERC721AStorage.sol";
import "../ERC721A__Initializable.sol";

abstract contract ERC721AOwnersExplicitUpgradeable is ERC721A__Initializable, ERC721AUpgradeable {
    using ERC721AStorage for ERC721AStorage.Layout;
    using ERC721AOwnersExplicitStorage for ERC721AOwnersExplicitStorage.Layout;
    function __ERC721AOwnersExplicit_init() internal onlyInitializingERC721A {
        __ERC721AOwnersExplicit_init_unchained();
    }

    function __ERC721AOwnersExplicit_init_unchained() internal onlyInitializingERC721A {
    }
    /**
     * No more ownership slots to explicity initialize.
     */
    error AllOwnershipsHaveBeenSet();
    
    /**
     * The `quantity` must be more than zero.
     */
    error QuantityMustBeNonZero();
    
    /**
     * At least one token needs to be minted.
     */
    error NoTokensMintedYet();

    /**
     * @dev Explicitly set `owners` to eliminate loops in future calls of ownerOf().
     */
    function _setOwnersExplicit(uint256 quantity) internal {
        if (quantity == 0) revert QuantityMustBeNonZero();
        if (ERC721AStorage.layout()._currentIndex == _startTokenId()) revert NoTokensMintedYet();
        uint256 _nextOwnerToExplicitlySet = ERC721AOwnersExplicitStorage.layout().nextOwnerToExplicitlySet;
        if (_nextOwnerToExplicitlySet == 0) {
            _nextOwnerToExplicitlySet = _startTokenId();
        }
        if (_nextOwnerToExplicitlySet >= ERC721AStorage.layout()._currentIndex) revert AllOwnershipsHaveBeenSet();

        // Index underflow is impossible.
        // Counter or index overflow is incredibly unrealistic.
        unchecked {
            uint256 endIndex = _nextOwnerToExplicitlySet + quantity - 1;

            // Set the end index to be the last token index
            if (endIndex + 1 > ERC721AStorage.layout()._currentIndex) {
                endIndex = ERC721AStorage.layout()._currentIndex - 1;
            }

            for (uint256 i = _nextOwnerToExplicitlySet; i <= endIndex; i++) {
                if (ERC721AStorage.layout()._ownerships[i].addr == address(0) && !ERC721AStorage.layout()._ownerships[i].burned) {
                    TokenOwnership memory ownership = _ownershipOf(i);
                    ERC721AStorage.layout()._ownerships[i].addr = ownership.addr;
                    ERC721AStorage.layout()._ownerships[i].startTimestamp = ownership.startTimestamp;
                }
            }

            ERC721AOwnersExplicitStorage.layout().nextOwnerToExplicitlySet = endIndex + 1;
        }
    }
    // generated getter for ${varDecl.name}
    function nextOwnerToExplicitlySet() public view returns(uint256) {
        return ERC721AOwnersExplicitStorage.layout().nextOwnerToExplicitlySet;
    }

}
