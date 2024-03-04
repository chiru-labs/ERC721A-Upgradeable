// SPDX-License-Identifier: MIT
// ERC721A Contracts v4.3.0
// Creators: Chiru Labs

pragma solidity ^0.8.4;
import '../ERC721A__Initializable.sol';

contract DirectBurnBitSetterHelperUpgradeable is ERC721A__Initializable {
    function __DirectBurnBitSetterHelper_init() internal onlyInitializingERC721A {
        __DirectBurnBitSetterHelper_init_unchained();
    }

    function __DirectBurnBitSetterHelper_init_unchained() internal onlyInitializingERC721A {}

    function directSetBurnBit(uint256 index) public virtual {
        bytes32 erc721aDiamondStorageSlot = keccak256('ERC721A.contracts.storage.ERC721A');

        // This is `_BITMASK_BURNED` from ERC721A.
        uint256 bitmaskBurned = 1 << 224;
        // We use assembly to directly access the private mapping.
        assembly {
            // The `_packedOwnerships` mapping is at slot 4.
            mstore(0x20, 4)
            mstore(0x00, index)
            let ownershipStorageSlot := keccak256(0x00, 0x40)
            sstore(ownershipStorageSlot, or(sload(ownershipStorageSlot), bitmaskBurned))

            // For diamond storage, we'll simply add the offset of the layout struct.
            mstore(0x20, add(erc721aDiamondStorageSlot, 4))
            mstore(0x00, index)
            ownershipStorageSlot := keccak256(0x00, 0x40)
            sstore(ownershipStorageSlot, or(sload(ownershipStorageSlot), bitmaskBurned))
        }
    }
}
