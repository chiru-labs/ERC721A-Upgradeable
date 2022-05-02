// SPDX-License-Identifier: MIT
// ERC721A Contracts v3.3.0
// Creator: Chiru Labs

pragma solidity ^0.8.4;

import "../ERC721AUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

abstract contract ERC721AOwnersExplicitUpgradeable is Initializable, ERC721AUpgradeable {
    function __ERC721AOwnersExplicit_init() internal onlyInitializing {
    }

    function __ERC721AOwnersExplicit_init_unchained() internal onlyInitializing {
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

    uint256 public nextOwnerToExplicitlySet;

    /**
     * @dev Explicitly set `owners` to eliminate loops in future calls of ownerOf().
     */
    function _setOwnersExplicit(uint256 quantity) internal {
        if (quantity == 0) revert QuantityMustBeNonZero();
        if (_currentIndex == _startTokenId()) revert NoTokensMintedYet();
        uint256 _nextOwnerToExplicitlySet = nextOwnerToExplicitlySet;
        if (_nextOwnerToExplicitlySet == 0) {
            _nextOwnerToExplicitlySet = _startTokenId();
        }
        if (_nextOwnerToExplicitlySet >= _currentIndex) revert AllOwnershipsHaveBeenSet();

        // Index underflow is impossible.
        // Counter or index overflow is incredibly unrealistic.
        unchecked {
            uint256 endIndex = _nextOwnerToExplicitlySet + quantity - 1;

            // Set the end index to be the last token index
            if (endIndex + 1 > _currentIndex) {
                endIndex = _currentIndex - 1;
            }

            for (uint256 i = _nextOwnerToExplicitlySet; i <= endIndex; i++) {
                if (_ownerships[i].addr == address(0) && !_ownerships[i].burned) {
                    TokenOwnership memory ownership = _ownershipOf(i);
                    _ownerships[i].addr = ownership.addr;
                    _ownerships[i].startTimestamp = ownership.startTimestamp;
                }
            }

            nextOwnerToExplicitlySet = endIndex + 1;
        }
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}
