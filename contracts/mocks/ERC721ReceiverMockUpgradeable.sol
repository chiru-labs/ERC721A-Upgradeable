// SPDX-License-Identifier: MIT
// ERC721A Contracts v3.3.0
// Creators: Chiru Labs

pragma solidity ^0.8.4;

import "@openzeppelin/contracts-upgradeable/token/ERC721/IERC721ReceiverUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract ERC721ReceiverMockUpgradeable is Initializable, IERC721ReceiverUpgradeable {
    enum Error {
        None,
        RevertWithMessage,
        RevertWithoutMessage,
        Panic
    }

    bytes4 private _retval;

    event Received(address operator, address from, uint256 tokenId, bytes data, uint256 gas);

    function __ERC721ReceiverMock_init(bytes4 retval) internal onlyInitializing {
        __ERC721ReceiverMock_init_unchained(retval);
    }

    function __ERC721ReceiverMock_init_unchained(bytes4 retval) internal onlyInitializing {
        _retval = retval;
    }

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes memory data
    ) public override returns (bytes4) {
        emit Received(operator, from, tokenId, data, 20000);
        return _retval;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}
