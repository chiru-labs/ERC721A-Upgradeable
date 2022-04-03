// SPDX-License-Identifier: MIT
// Creators: Chiru Labs

pragma solidity ^0.8.4;

import "../extensions/ERC721APausableUpgradeable.sol";
import "../extensions/ERC721ABurnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract ERC721APausableMockUpgradeable is Initializable, ERC721AUpgradeable, ERC721APausableUpgradeable, ERC721ABurnableUpgradeable {
    function __ERC721APausableMock_init(string memory name_, string memory symbol_) internal onlyInitializing {
        __ERC721A_init_unchained(name_, symbol_);
        __Pausable_init_unchained();
    }

    function __ERC721APausableMock_init_unchained(string memory, string memory) internal onlyInitializing {}

    function safeMint(address to, uint256 quantity) public {
        _safeMint(to, quantity);
    }

    function _beforeTokenTransfers(
        address from,
        address to,
        uint256 startTokenId,
        uint256 quantity
    ) internal virtual override(ERC721AUpgradeable, ERC721APausableUpgradeable) {
        super._beforeTokenTransfers(from, to, startTokenId, quantity);
    }

    function pause() external {
        _pause();
    }

    function unpause() external {
        _unpause();
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}
