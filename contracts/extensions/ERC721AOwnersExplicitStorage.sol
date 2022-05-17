// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;


import { ERC721AOwnersExplicitUpgradeable } from "./ERC721AOwnersExplicitUpgradeable.sol";

library ERC721AOwnersExplicitStorage {

  struct Layout {

    // The next token ID to explicity initialize ownership data.
    uint256 _currentIndexOwnersExplicit;
  
  }
  
  bytes32 internal constant STORAGE_SLOT = keccak256('ERC721A.contracts.storage.ERC721AOwnersExplicit');

  function layout() internal pure returns (Layout storage l) {
    bytes32 slot = STORAGE_SLOT;
    assembly {
      l.slot := slot
    }
  }
}
    
