// SPDX-License-Identifier: MIT
// Creator: Chiru Labs

pragma solidity ^0.8.4;

import "../ERC721AUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

/**
 * @title ERC721A Low Cap
 * @dev ERC721A Helper functions for Low Cap (<= 10,000) totalSupply.
 */
abstract contract ERC721ALowCapUpgradeable is Initializable, ERC721AUpgradeable {
    function __ERC721ALowCap_init() internal onlyInitializing {
    }

    function __ERC721ALowCap_init_unchained() internal onlyInitializing {
    }
    /**
     * @dev Returns the tokenIds of the address. O(totalSupply) in complexity.
     */
    function tokensOfOwner(address owner) public view returns (uint256[] memory) {
        uint256 holdingAmount = balanceOf(owner);
        uint256 currSupply = _currentIndex;
        uint256 tokenIdsIdx;
        address currOwnershipAddr;

        uint256[] memory list = new uint256[](holdingAmount);

        unchecked {
            for (uint256 i = _startTokenId(); i < currSupply; ++i) {
                TokenOwnership memory ownership = _ownerships[i];

                if (ownership.burned) {
                    continue;
                }

                // Find out who owns this sequence
                if (ownership.addr != address(0)) {
                    currOwnershipAddr = ownership.addr;
                }

                // Append tokens the last found owner owns in the sequence
                if (currOwnershipAddr == owner) {
                    list[tokenIdsIdx++] = i;
                }

                // All tokens have been found, we don't need to keep searching
                if (tokenIdsIdx == holdingAmount) {
                    break;
                }
            }
        }

        return list;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}
