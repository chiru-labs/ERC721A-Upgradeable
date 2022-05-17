// SPDX-License-Identifier: MIT
// ERC721A Contracts v3.3.0
// Creators: Chiru Labs

pragma solidity ^0.8.4;

import "../ERC721AUpgradeable.sol";
import { ERC721ReceiverMockStorage } from "./ERC721ReceiverMockStorage.sol";
import "../ERC721A__Initializable.sol";

contract ERC721ReceiverMockUpgradeable is ERC721A__Initializable, ERC721A__IERC721ReceiverUpgradeable {
    using ERC721ReceiverMockStorage for ERC721ReceiverMockStorage.Layout;
    enum Error {
        None,
        RevertWithMessage,
        RevertWithoutMessage,
        Panic
    }

    event Received(address operator, address from, uint256 tokenId, bytes data, uint256 gas);

    function __ERC721ReceiverMock_init(bytes4 retval) internal onlyInitializingERC721A {
        __ERC721ReceiverMock_init_unchained(retval);
    }

    function __ERC721ReceiverMock_init_unchained(bytes4 retval) internal onlyInitializingERC721A {
        ERC721ReceiverMockStorage.layout()._retval = retval;
    }

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes memory data
    ) public override returns (bytes4) {
        emit Received(operator, from, tokenId, data, 20000);
        return ERC721ReceiverMockStorage.layout()._retval;
    }
}
