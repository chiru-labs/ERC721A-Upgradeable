// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;


import { ERC721AOwnersExplicitUpgradeable } from "./ERC721AOwnersExplicitUpgradeable.sol";
import { ERC721AUpgradeable } from "../ERC721AUpgradeable.sol";
import { IERC721AUpgradeable } from "../IERC721AUpgradeable.sol";

library ERC721AOwnersExplicitStorage {

  struct Layout {

    uint256 nextOwnerToExplicitlySet;
  
  }
  
  bytes32 internal constant STORAGE_SLOT = keccak256('openzepplin.contracts.storage.ERC721AOwnersExplicit');

  function layout() internal pure returns (Layout storage l) {
    bytes32 slot = STORAGE_SLOT;
    assembly {
      l.slot := slot
    }
  }
}
    
