// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;


import { ERC721AUpgradeable } from "./ERC721AUpgradeable.sol";
import { IERC721AUpgradeable } from "./IERC721AUpgradeable.sol";

library ERC721AStorage {

  struct Layout {
    // The tokenId of the next token to be minted.
    uint256 _currentIndex;

    // The number of tokens burned.
    uint256 _burnCounter;

    // Token name
    string _name;

    // Token symbol
    string _symbol;

    // Mapping from token ID to ownership details
    // An empty struct value does not necessarily mean the token is unowned. See _ownershipOf implementation for details.
    mapping(uint256 => IERC721AUpgradeable.TokenOwnership) _ownerships;

    // Mapping owner address to address data
    mapping(address => IERC721AUpgradeable.AddressData) _addressData;

    // Mapping from token ID to approved address
    mapping(uint256 => address) _tokenApprovals;

    // Mapping from owner to operator approvals
    mapping(address => mapping(address => bool)) _operatorApprovals;
  
  }
  
  bytes32 internal constant STORAGE_SLOT = keccak256('ERC721A.contracts.storage.ERC721A');

  function layout() internal pure returns (Layout storage l) {
    bytes32 slot = STORAGE_SLOT;
    assembly {
      l.slot := slot
    }
  }
}
    
