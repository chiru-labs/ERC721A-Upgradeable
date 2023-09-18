// SPDX-License-Identifier: MIT
// Based on ERC721A Implementation.

pragma solidity ^0.8.10;

import './interfaces/IERC721A.sol';
import './interfaces/IERC721Receiver.sol';

struct Config {
    // Enough for the next ~80 years.
    uint32 deployTime;
    // Enough to stake for a lifetime. Staking disabled if eq to 0.
    uint32 minStakingTime;
    // Enough to stake for a lifetime.
    uint32 automaticStakeTimeOnMint;
    // Enough to stake for a lifetime.
    uint32 automaticStakeTimeOnTx;
    string name;
    string symbol;
}

// @dev Used for constructor, because `deployTime` should be set automatically.
struct DeploymentConfig {
    uint32 minStakingTime;
    uint32 automaticStakeTimeOnMint;
    uint32 automaticStakeTimeOnTx;
    string name;
    string symbol;
}

struct TokenOwnership {
    address owner;
    uint32 totalStakedTime;
    uint32 stakingStart;
    uint32 stakingDuration;
}

error StakeCallerNotOwnerNorApproved();

/**
 * @title ERC721S
 *
 * @dev This contract implements a novel staking mechanism:
 * 
 * - Tokens can get automatically staked on mint for a certain amount of time.
 * - Tokens can get automatically staked on tx for a certain amount of time.
 * - If not, tokens can get manually staked by the user.
 *
 * In any of those cases, the user will be able to extend staking time, if not,
 * the token will get automatically unstaked to minimize contract interaction.
 */
contract ERC721S is IERC721A {
    // Bypass for a `--via-ir` bug (https://github.com/chiru-labs/ERC721A/pull/364).
    struct TokenApprovalRef {
        address value;
    }

    // =============================================================
    //                           CONSTANTS
    // =============================================================

    // Config bit positions.
        uint256 internal constant _BITPOS_MIN_STAKING_TIME = 32;
        uint256 internal constant _BITPOS_STAKING_TIME_ON_MINT = 64;
        uint256 internal constant _BITPOS_STAKING_TIME_ON_TX = 96;

    // Address data masks and bit positions.

        // Mask of an entry in packed address data.
        uint256 internal constant _BITMASK_ADDRESS_DATA_ENTRY = (1 << 64) - 1;

        // The bit position of `numberMinted` in packed address data.
        uint256 internal constant _BITPOS_NUMBER_MINTED = 64;

        // The bit position of `aux` in packed address data.
        uint256 internal constant _BITPOS_AUX = 128;

        // Mask of all 256 bits in packed address data except the 128 bits for `aux`.
        uint256 internal constant _BITMASK_AUX_COMPLEMENT = (1 << 128) - 1;
    
    // Ownership data masks and bit positions.

        // The mask of the lower 160 bits for addresses.
        uint256 internal constant _BITMASK_ADDRESS = (1 << 160) - 1;

        // Mask for staking info entries (they all are of size 32 bits).
        uint256 internal constant _BITMASK_STAKING_INFO = (1 << 32) - 1;

        // Bit position for the total time staked.
        uint256 internal constant _BITPOS_TOTAL_STAKED_TIME = 160;

        // Bit position for the timestamp relative to deploy time
        // at which a token was staked, assuming it was.
        uint256 internal constant _BITPOS_STAKING_START = 192;

        // Bit position for the total duration a token is being staked.
        uint256 internal constant _BITPOS_STAKING_DURATION = 224;

    // Extra constants.

        // The `Transfer` event signature is given by:
        // `keccak256(bytes("Transfer(address,address,uint256)"))`.
        bytes32 internal constant _TRANSFER_EVENT_SIGNATURE =
            0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef;

        // Selector for `TokenStaked()` error.
        bytes4 internal constant _TOKEN_STAKED_ERROR_SELECTOR = 0x538fd4df;

        // Selector for `WrongContractStakingConfig()` error.
        bytes4 internal constant _WRONG_STAKING_CONFIG_ERROR_SELECTOR = 0x5590a6d1;

        // Selector for `WrongStakingTime()` error.
        bytes4 internal constant _WRONG_STAKING_TIME_ERROR_SELECTOR = 0xac53100b;

        // TODO
        bytes4 internal constant _STAKING_DISABLED_ERROR_SELECTOR = 0x12345678;

        // Extra bitmask for 64 bits data.
        uint256 internal constant _BITMASK64 = (1 << 64) - 1;
    

    // =============================================================
    //                            STORAGE
    // =============================================================

    // The next token ID to be minted.
    uint256 private _currentIndex;

    // Mapping from token ID to ownership details
    // An empty struct value does not necessarily mean the token is unowned.
    // See {_packedOwnershipOf} implementation for details.
    //
    // Bits Layout:
    // - [0..159]   `addr`
    // - [160..191] `totalStakedTime`
    // - [192..223] `stakingStart`
    // - [223..255] `stakingDuration`
    mapping(uint256 => uint256) internal _packedOwnerships;

    // Mapping owner address to address data.
    //
    // Bits Layout:
    // - [0..63]    `balance`
    // - [64..127]  `numberMinted`
    // - [128..255] `aux`
    mapping(address => uint256) private _packedAddressData;

    // Mapping from token ID to approved address.
    mapping(uint256 => TokenApprovalRef) private _tokenApprovals;

    // Mapping from owner to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;
    
    // General contract config, decided by the owner, to handle different 
    // staking strategies. Note that this variable will be internal because 
    // its immutable for this contract, but could mutate via inheritance.
    Config internal _config;


    // =============================================================
    //                          CONSTRUCTOR
    // =============================================================

    constructor(DeploymentConfig memory config_) {
        unchecked {
            _config = Config(
                uint32(block.timestamp),
                config_.minStakingTime,
                config_.automaticStakeTimeOnMint,
                config_.automaticStakeTimeOnTx,
                config_.name,
                config_.symbol
            );
        }
        _currentIndex = _startTokenId();
    }

    // =============================================================
    //                   TOKEN COUNTING OPERATIONS
    // =============================================================

    /**
     * @dev Returns the starting token ID.
     * To change the starting token ID, please override this function.
     */
    function _startTokenId() internal view virtual returns (uint256) {
        return 0;
    }

    /**
     * @dev Returns the next token ID to be minted.
     */
    function _nextTokenId() internal view virtual returns (uint256) {
        return _currentIndex;
    }

    /**
     * @dev Returns the total number of tokens in existence.
     */
    function totalSupply() public view virtual override returns (uint256) {
        // Counter underflow is impossible as _burnCounter cannot be incremented
        // more than `_currentIndex - _startTokenId()` times.
        unchecked {
            return _currentIndex - _startTokenId();
        }
    }

    // =============================================================
    //                    ADDRESS DATA OPERATIONS
    // =============================================================

    /**
     * @dev Returns the number of tokens in `owner`'s account.
     */
    function balanceOf(address owner) public view virtual override returns (uint256) {
        if (owner == address(0)) _revert(BalanceQueryForZeroAddress.selector);
        return _packedAddressData[owner] & _BITMASK_ADDRESS_DATA_ENTRY;
    }

    /**
     * Returns the number of tokens minted by `owner`.
     */
    function _numberMinted(address owner) internal view returns (uint256) {
        return (_packedAddressData[owner] >> _BITPOS_NUMBER_MINTED) & _BITMASK_ADDRESS_DATA_ENTRY;
    }

    /**
     * Returns the auxiliary data for `owner`. (e.g. number of whitelist mint slots used).
     */
    function _getAux(address owner) internal view returns (uint128) {
        return uint128(_packedAddressData[owner] >> _BITPOS_AUX);
    }

    /**
     * Sets the auxiliary data for `owner`. (e.g. number of whitelist mint slots used).
     * If there are multiple variables, please pack them into a uint64.
     */
    function _setAux(address owner, uint128 aux) internal virtual {
        uint256 packed = _packedAddressData[owner];
        uint256 auxCasted;
        // Cast `aux` with assembly to avoid redundant masking.
        assembly {
            auxCasted := aux
        }
        packed = (packed & _BITMASK_AUX_COMPLEMENT) | (auxCasted << _BITPOS_AUX);
        _packedAddressData[owner] = packed;
    }

    // =============================================================
    //                            IERC165
    // =============================================================

    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * [EIP section](https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified)
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30000 gas.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        // The interface IDs are constants representing the first 4 bytes
        // of the XOR of all function selectors in the interface.
        // See: [ERC165](https://eips.ethereum.org/EIPS/eip-165)
        // (e.g. `bytes4(i.functionA.selector ^ i.functionB.selector ^ ...)`)
        return
            interfaceId == 0x01ffc9a7 || // ERC165 interface ID for ERC165.
            interfaceId == 0x80ac58cd || // ERC165 interface ID for ERC721.
            interfaceId == 0x5b5e139f; // ERC165 interface ID for ERC721Metadata.
    }

    // =============================================================
    //                        IERC721Metadata
    // =============================================================

    /**
     * @dev Returns the token collection name.
     */
    function name() public view virtual override returns (string memory) {
        return _config.name;
    }

    /**
     * @dev Returns the token collection symbol.
     */
    function symbol() public view virtual override returns (string memory) {
        return _config.symbol;
    }

    /**
     * @dev Returns the Uniform Resource Identifier (URI) for `tokenId` token.
     */
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        if (!_exists(tokenId)) _revert(URIQueryForNonexistentToken.selector);

        string memory baseURI = _baseURI();
        return bytes(baseURI).length != 0 
            ? string(abi.encodePacked(baseURI, _toString(tokenId))) 
            : '';
    }

    /**
     * @dev Base URI for computing {tokenURI}. If set, the resulting URI for each
     * token will be the concatenation of the `baseURI` and the `tokenId`. Empty
     * by default, it can be overridden in child contracts.
     */
    function _baseURI() internal view virtual returns (string memory) {
        return '';
    }

    // =============================================================
    //                     OWNERSHIPS OPERATIONS
    // =============================================================

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) public view virtual override returns (address) {
        return address(uint160(_packedOwnershipOf(tokenId)));
    }

    function _ownershipOf(uint256 tokenId) internal view virtual returns (TokenOwnership memory) {
        return _unpackedOwnership(_packedOwnershipOf(tokenId)); 
    }
    
    /**
     * @dev Returns whether the ownership slot at `index` is initialized.
     * An uninitialized slot does not necessarily mean that the slot has no owner.
     */
    function _ownershipIsInitialized(uint256 index) internal view virtual returns (bool) {
        return _packedOwnerships[index] != 0;
    }

    /**
     * Returns the packed ownership data of `tokenId`.
     */
    function _packedOwnershipOf(uint256 tokenId) internal view returns (uint256 packed) {
        if (_startTokenId() <= tokenId) {
            packed = _packedOwnerships[tokenId];
            // If the data at the starting slot does not exist, start the scan.
            if (packed == 0) {
                if (tokenId >= _currentIndex) _revert(OwnerQueryForNonexistentToken.selector);
                // Invariant:
                // There will always be an initialized ownership slot
                // (i.e. `ownership.addr != address(0) && ownership.burned == false`)
                // before an unintialized ownership slot
                // (i.e. `ownership.addr == address(0) && ownership.burned == false`)
                // Hence, `tokenId` will not underflow.
                //
                // We can directly compare the packed value.
                // If the address is zero, packed will be zero.
                while (true) {
                    unchecked {
                        packed = _packedOwnerships[--tokenId];
                    }
                    if (packed != 0) return packed;
                }
            }
            // Otherwise, the data exists and we can skip the scan.
            // This is possible because we have already achieved the target condition.
            // This saves 2143 gas on transfers of initialized tokens.
            // If the token is not burned, return `packed`. Otherwise, revert.
            return packed;
        }
        _revert(OwnerQueryForNonexistentToken.selector);
    }

    function _unpackedOwnership(uint256 packedOwnership) internal pure returns (TokenOwnership memory ownership) {
        ownership.owner = address(uint160(packedOwnership)); 
        ownership.totalStakedTime = uint32(packedOwnership >> _BITPOS_TOTAL_STAKED_TIME);
        ownership.stakingStart = uint32(packedOwnership >> _BITPOS_STAKING_START);
        ownership.stakingDuration = uint32(packedOwnership >> _BITPOS_STAKING_DURATION);
    }

    /**
     * Requirements:
     *
     * - Staking on mint must be enabled (`_config.automaticStakeTimeOnMint > 0`).
     */
    function _packStakingDataForMint(address owner) internal view returns (uint256 result) {
        assembly {
            let conf := sload(_config.slot)

            // If the token shouldn't get staked on tx, revert.
            let onMintStakingTime := and(shr(_BITPOS_STAKING_TIME_ON_MINT, conf), _BITMASK_STAKING_INFO)
            if iszero(onMintStakingTime) {
                mstore(0x00, _WRONG_STAKING_CONFIG_ERROR_SELECTOR)
                revert(0x00, 0x04)
            }
            // Otherwise, set that staking time.
            result := shl(_BITPOS_STAKING_DURATION, onMintStakingTime)

            // Then, set the staking start timestamp relative to the deployment time.
            let deployTime := and(conf, _BITMASK_STAKING_INFO)
            let stakingStart := sub(timestamp(), deployTime)
            result := or(result, shl(_BITPOS_STAKING_START, stakingStart))

            // Finally, pack all the staking info with the owner and return it.
            result := or(result, owner)
        }
    }

    /**
     * Requirements:
     *
     * - The token must be unstaked.
     */
    function _packOwnershipDataForTx(address newOwner, uint256 oldOwnership) internal view returns (uint256 result) {
        assembly {

            let conf := sload(_config.slot)
            let deploymentTime := and(conf, _BITMASK_STAKING_INFO)

            // SET STAKING DURATION IF THE TOKEN SHOULD GET STAKED ON TX.
            { 
                let stakingDurationOnTx := and(shr(_BITPOS_STAKING_TIME_ON_TX, conf), _BITMASK_STAKING_INFO)
                // If the token should get staked on tx, set that staking data into the result.
                if eq(iszero(stakingDurationOnTx), 0) {
                    // Calc relative staking start to the deployment time.
                    let newRelativeStakingStart := sub(timestamp(), deploymentTime)
                    // Concat the staking start to the total time the token is gonna be staked.
                    result := or(
                        shl(_BITPOS_STAKING_DURATION, stakingDurationOnTx),
                        shl(_BITPOS_STAKING_START, newRelativeStakingStart)
                    )
                }
            }

            let oldStakingDuration := and(shr(_BITPOS_STAKING_DURATION, oldOwnership), _BITMASK_STAKING_INFO)

            // REVERT IF THE TOKEN IS STAKED.
            {
                // If the old staking staking duration is 0, that means that the token was 
                // not staked, or that that it was already unstaked.
                if eq(iszero(oldStakingDuration), 0) {
                    // Calc the staking start based on the deployment time and the relative staking start.
                    let oldRelativeStakingStart := and(shr(_BITPOS_STAKING_START, oldOwnership), _BITMASK_STAKING_INFO)
                    let oldStakingStart := add(deploymentTime, oldRelativeStakingStart)
                    // If the staking end time is greater than the current block timestamp, revert.
                    if gt(add(oldStakingStart, oldStakingDuration), timestamp()) {
                        mstore(0x00, _TOKEN_STAKED_ERROR_SELECTOR)
                        revert(0x00, 0x04)
                    }
                }
                
            }

            // UPDATE THE TOTAL TIME STAKED BASED ON THE LAST STAKE.
            {
                let totalTimeStaked := and(shr(_BITPOS_TOTAL_STAKED_TIME, oldOwnership), _BITMASK_STAKING_INFO)

                // Wont overflow in the next ~136 years.
                // Will be redudant if the token was already unstaked or never staked, 
                // in which case, `oldStakingDuraion == 0`.
                totalTimeStaked := add(
                    totalTimeStaked,
                    oldStakingDuration
                )

                // Append the new owner and the total time staked to the result.
                result := or(result, or(
                    shl(_BITPOS_TOTAL_STAKED_TIME, totalTimeStaked),
                    and(newOwner, _BITMASK_ADDRESS)
                ))
            }

        }
    }

    /**
     * Requirements:
     *
     * - The token must be unstaked.
     * - Staking must be enabled (`_config_minStakingTime  > 0`).
     */
    function _updateOwnershipDataForStaking(uint256 oldOwnership, uint32 time) internal view returns (uint256 result) {
        assembly {
            let conf := sload(_config.slot)
            let deploymentTime := and(conf, _BITMASK_STAKING_INFO)

            // REVERT IF `time` IS LESS THAN THE MIN STAKING TIME OR IF STAKING DISABLED.
            {
                let minStakingTime := and(shr(_BITPOS_MIN_STAKING_TIME, conf), _BITMASK_STAKING_INFO)
                if iszero(minStakingTime) {
                    mstore(0x00, _STAKING_DISABLED_ERROR_SELECTOR)
                    revert(0x00, 0x40)
                }
                if lt(time, minStakingTime) {
                    mstore(0x00, _WRONG_STAKING_TIME_ERROR_SELECTOR)
                    revert(0x00, 0x04)
                }
            }

            let oldStakingDuration := and(shr(_BITPOS_STAKING_DURATION, oldOwnership), _BITMASK_STAKING_INFO)

            // REVERT IF THE TOKEN IS STAKED.
            {
                // If the old staking duration is 0, that means that the token was 
                // not staked, or that it was already unstaked.
                if eq(iszero(oldStakingDuration), 0) {
                    // Calc the staking start based on the deployment time and the relative staking start.
                    let oldRelativeStakingStart := and(shr(_BITPOS_STAKING_START, oldOwnership), _BITMASK_STAKING_INFO)
                    let oldStakingStart := add(deploymentTime, oldRelativeStakingStart)
                    // If the staking end time is greater than the current block timestamp, revert.
                    if gt(add(oldStakingStart, oldStakingDuration), timestamp()) {
                        mstore(0x00, _TOKEN_STAKED_ERROR_SELECTOR)
                        revert(0x00, 0x04)
                    }
                }
                
            }

            // PACK ALL STAKING DATA.
            {
                // Clean all ownership data other than the owner.
                result := and(oldOwnership, _BITMASK_ADDRESS)

                // Concat result to the staking duration.
                result := or(result, shl(_BITPOS_STAKING_DURATION, time))

                // Calc relative staking start to the deployment time.
                let stakingStart := sub(timestamp(), time)
                // Concat result to the staking start.
                result := or(result, shl(_BITPOS_STAKING_START, stakingStart))

                // Update total time staked based on the last stake.
                let totalTimeStaked := and(shr(_BITPOS_TOTAL_STAKED_TIME, oldOwnership), _BITMASK_STAKING_INFO)
                // Wont overflow in the next ~136 years.
                totalTimeStaked := add(totalTimeStaked, oldStakingDuration)
                // Concat result to the total time staked.
                result := or(result, shr(_BITPOS_TOTAL_STAKED_TIME, totalTimeStaked))
            }


        }
    }

    // =============================================================
    //                      APPROVAL OPERATIONS
    // =============================================================

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account. See {ERC721A-_approve}.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     */
    function approve(address to, uint256 tokenId) public payable virtual override {
        _approve(to, tokenId, true);
    }

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) public view virtual override returns (address) {
        if (!_exists(tokenId)) _revert(ApprovalQueryForNonexistentToken.selector);
        return _tokenApprovals[tokenId].value;
    }

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom}
     * for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool approved) public virtual override {
        _operatorApprovals[_msgSenderERC721A()][operator] = approved;
        emit ApprovalForAll(_msgSenderERC721A(), operator, approved);
    }

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}.
     */
    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    /**
     * @dev Returns whether `tokenId` exists.
     *
     * Tokens can be managed by their owner or approved accounts via {approve} or {setApprovalForAll}.
     *
     * Tokens start existing when they are minted. See {_mint}.
     */
    function _exists(uint256 tokenId) internal view virtual returns (bool result) {
        return tokenId >= _startTokenId() && tokenId < _currentIndex;
    }

    /**
     * @dev Returns whether `msgSender` is equal to `approvedAddress` or `owner`.
     */
    function _isSenderApprovedOrOwner(
        address approvedAddress,
        address owner,
        address msgSender
    ) private pure returns (bool result) {
        assembly {
            // Mask `owner` to the lower 160 bits, in case the upper bits somehow aren't clean.
            owner := and(owner, _BITMASK_ADDRESS)
            // Mask `msgSender` to the lower 160 bits, in case the upper bits somehow aren't clean.
            msgSender := and(msgSender, _BITMASK_ADDRESS)
            // `msgSender == owner || msgSender == approvedAddress`.
            result := or(eq(msgSender, owner), eq(msgSender, approvedAddress))
        }
    }

    /**
     * @dev Returns the storage slot and value for the approved address of `tokenId`.
     */
    function _getApprovedSlotAndAddress(uint256 tokenId)
        private
        view
        returns (uint256 approvedAddressSlot, address approvedAddress)
    {
        TokenApprovalRef storage tokenApproval = _tokenApprovals[tokenId];
        // The following is equivalent to `approvedAddress = _tokenApprovals[tokenId].value`.
        assembly {
            approvedAddressSlot := tokenApproval.slot
            approvedAddress := sload(approvedAddressSlot)
        }
    }

    // =============================================================
    //                      TRANSFER OPERATIONS
    // =============================================================

    /**
     * @dev Transfers `tokenId` from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - `tokenId` can't be staked.
     * - If the caller is not `from`, it must be approved to move this token
     * by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public payable virtual override {
        uint256 prevOwnershipPacked = _packedOwnershipOf(tokenId);

        // Mask `from` to the lower 160 bits, in case the upper bits somehow aren't clean.
        from = address(uint160(uint256(uint160(from)) & _BITMASK_ADDRESS));

        if (address(uint160(prevOwnershipPacked)) != from) _revert(TransferFromIncorrectOwner.selector);

        (uint256 approvedAddressSlot, address approvedAddress) = _getApprovedSlotAndAddress(tokenId);

        // The nested ifs save around 20+ gas over a compound boolean condition.
        if (!_isSenderApprovedOrOwner(approvedAddress, from, _msgSenderERC721A()))
            if (!isApprovedForAll(from, _msgSenderERC721A())) 
                _revert(TransferCallerNotOwnerNorApproved.selector);

        _beforeTokenTransfers(from, to, tokenId, 1);

        // Clear approvals from the previous owner.
        assembly {
            if approvedAddress {
                // This is equivalent to `delete _tokenApprovals[tokenId]`.
                sstore(approvedAddressSlot, 0)
            }
        }

        // Underflow of the sender's balance is impossible because we check for
        // ownership above and the recipient's balance can't realistically overflow.
        // Counter overflow is incredibly unrealistic as `tokenId` would have to be 2**256.
        unchecked {
            // We can directly increment and decrement the balances.
            --_packedAddressData[from]; // Updates: `balance -= 1`.
            ++_packedAddressData[to]; // Updates: `balance += 1`.

            // Calc new ownership, revert if the token is staked.
            _packedOwnerships[tokenId] = _packOwnershipDataForTx(to, prevOwnershipPacked);

            // Load next ownership slot and update it if needed.
            uint256 nextOwnership = _packedOwnerships[tokenId + 1];
            if (tokenId + 1 < _currentIndex && nextOwnership == 0) {
                _packedOwnerships[tokenId + 1] = prevOwnershipPacked;
            }

        }

        // Mask `to` to the lower 160 bits, in case the upper bits somehow aren't clean.
        uint256 toMasked = uint256(uint160(to)) & _BITMASK_ADDRESS;
        assembly {
            // Emit the `Transfer` event.
            log4(
                0, // Start of data (0, since no data).
                0, // End of data (0, since no data).
                _TRANSFER_EVENT_SIGNATURE, // Signature.
                from, // `from`.
                toMasked, // `to`.
                tokenId // `tokenId`.
            ) 

            // TODO Emit the 'TokenStaked' event if it was.
        }
        if (toMasked == 0) _revert(TransferToZeroAddress.selector);

        _afterTokenTransfers(from, to, tokenId, 1);
    }

    /**
     * @dev Equivalent to `safeTransferFrom(from, to, tokenId, '')`.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public payable virtual override {
        safeTransferFrom(from, to, tokenId, '');
    }

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token
     * by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement
     * {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public payable virtual override {
        transferFrom(from, to, tokenId);
        if (to.code.length != 0)
            if (!_checkContractOnERC721Received(from, to, tokenId, _data))
                _revert(TransferToNonERC721ReceiverImplementer.selector);
    }

    /**
     * @dev Hook that is called before a set of serially-ordered token IDs
     * are about to be transferred. This includes minting.
     * And also called before burning one token.
     *
     * `startTokenId` - the first token ID to be transferred.
     * `quantity` - the amount to be transferred.
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, `from`'s `tokenId` will be
     * transferred to `to`.
     * - When `from` is zero, `tokenId` will be minted for `to`.
     * - When `to` is zero, `tokenId` will be burned by `from`.
     * - `from` and `to` are never both zero.
     */
    function _beforeTokenTransfers(
        address from,
        address to,
        uint256 startTokenId,
        uint256 quantity
    ) internal virtual {}

    /**
     * @dev Hook that is called after a set of serially-ordered token IDs
     * have been transferred. This includes minting.
     * And also called after one token has been burned.
     *
     * `startTokenId` - the first token ID to be transferred.
     * `quantity` - the amount to be transferred.
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, `from`'s `tokenId` has been
     * transferred to `to`.
     * - When `from` is zero, `tokenId` has been minted for `to`.
     * - When `to` is zero, `tokenId` has been burned by `from`.
     * - `from` and `to` are never both zero.
     */
    function _afterTokenTransfers(
        address from,
        address to,
        uint256 startTokenId,
        uint256 quantity
    ) internal virtual {}

    /**
     * @dev Private function to invoke {IERC721Receiver-onERC721Received} on a target contract.
     *
     * `from` - Previous owner of the given token ID.
     * `to` - Target address that will receive the token.
     * `tokenId` - Token ID to be transferred.
     * `_data` - Optional data to send along with the call.
     *
     * Returns whether the call correctly returned the expected magic value.
     */
    function _checkContractOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) private returns (bool) {
        try IERC721Receiver(to).onERC721Received(
            _msgSenderERC721A(), from, tokenId, _data
        ) returns (bytes4 retval) {
            return retval == IERC721Receiver(to).onERC721Received.selector;
        } catch (bytes memory reason) {
            if (reason.length == 0) {
                _revert(TransferToNonERC721ReceiverImplementer.selector);
            }
            assembly {
                revert(add(32, reason), mload(reason))
            }
        }
    }

    // =============================================================
    //                        MINT OPERATIONS
    // =============================================================

    function _mint(
        address to,
        uint256 quantity
    ) internal virtual {
        _mint(to, quantity, true);
    }

    /**
     * @dev Mints `quantity` tokens and transfers them to `to`.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `quantity` must be greater than 0.
     * - if `stake`, then _config.minStakingTimeOnMint must be greater than 0.
     *
     * Emits a {Transfer} event for each mint.
     */
    function _mint(
        address to,
        uint256 quantity,
        bool stakeOnMint
    ) internal virtual {
        uint256 startTokenId = _currentIndex;
        if (quantity == 0) _revert(MintZeroQuantity.selector);

        _beforeTokenTransfers(address(0), to, startTokenId, quantity);

        unchecked {
            // Mask `to` to the lower 160 bits, in case the upper bits somehow aren't clean.
            uint256 toMasked = uint256(uint160(to)) & _BITMASK_ADDRESS;
            if (toMasked == 0) _revert(MintToZeroAddress.selector);

            if (stakeOnMint)
                // Will revert if `stake` but the config for staking on mint is wrong.
                _packedOwnerships[startTokenId] = _packStakingDataForMint(to);
            else 
                // Otherwise, just store the new owner address.
                _packedOwnerships[startTokenId] = toMasked;

            // Updates:
            // - `balance += quantity`.
            // - `numberMinted += quantity`.
            //
            // We can directly add to the `balance` and `numberMinted`.
            _packedAddressData[to] += quantity * ((1 << _BITPOS_NUMBER_MINTED) | 1);

            uint256 end = startTokenId + quantity;
            uint256 tokenId;

            // If staking on mint is enabled for this batch, emit 
            // a staked event for each tokenId.
            if (stakeOnMint) {
                tokenId = startTokenId;
                do {
                    assembly {
                        // TODO Use Openseas staking standard.
                        // logN(
                        //     0,
                        //     0,
                        //     _STAKE_EVENT_SIGNATURE,
                        //     etc
                        // )
                    }
                } while (++tokenId != end);
            }

            tokenId = startTokenId;
            do {
                assembly {
                    // Emit the `Transfer` event.
                    log4(
                        0, // Start of data (0, since no data).
                        0, // End of data (0, since no data).
                        _TRANSFER_EVENT_SIGNATURE, // Signature.
                        0, // `address(0)`.
                        toMasked, // `to`.
                        tokenId // `tokenId`.
                    )
                }
                // The `!=` check ensures that large values of `quantity`
                // that overflows uint256 will make the loop run out of gas.
            } while (++tokenId != end);

            _currentIndex = end;
        }
        _afterTokenTransfers(address(0), to, startTokenId, quantity);
    }


    // =============================================================
    //                       APPROVAL OPERATIONS
    // =============================================================

    /**
     * @dev Equivalent to `_approve(to, tokenId, false)`.
     */
    function _approve(address to, uint256 tokenId) internal virtual {
        _approve(to, tokenId, false);
    }

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the
     * zero address clears previous approvals.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function _approve(
        address to,
        uint256 tokenId,
        bool approvalCheck
    ) internal virtual {
        address owner = ownerOf(tokenId);

        if (approvalCheck && _msgSenderERC721A() != owner)
            if (!isApprovedForAll(owner, _msgSenderERC721A())) {
                _revert(ApprovalCallerNotOwnerNorApproved.selector);
            }

        _tokenApprovals[tokenId].value = to;
        emit Approval(owner, to, tokenId);
    }

    // =============================================================
    //                       STAKING OPERATIONS 
    // =============================================================
    /**
     * @dev It will stake `tokenId` and all the following 
     *      successive tokens owned by the `tokenId` owner.
     */
    function stakeBatch(uint256 tokenId, uint32 time) public {

        uint256 oldOwnership = _packedOwnershipOf(tokenId);

        address msgSender = _msgSenderERC721A();
        address owner = address(uint160(oldOwnership));
        (, address approvedAddress) = _getApprovedSlotAndAddress(tokenId);

        if (!_isSenderApprovedOrOwner(approvedAddress, owner, _msgSenderERC721A()))
            if (!isApprovedForAll(owner, msgSender))
                _revert(StakeCallerNotOwnerNorApproved.selector);

        // Reverts if `time < _config.minStakingTime`.
        _packedOwnerships[tokenId] = _updateOwnershipDataForStaking(oldOwnership, time);

        // TODO Emit staking events.
    }

    /**
     * @dev It will only stake `tokenId`, doing the required ownership manipulations.
     */
    function stake(uint256 tokenId, uint32 time) public {
        uint256 oldOwnership = _packedOwnershipOf(tokenId);

        address msgSender = _msgSenderERC721A();
        address owner = address(uint160(oldOwnership));
        (, address approvedAddress) = _getApprovedSlotAndAddress(tokenId);

        if (!_isSenderApprovedOrOwner(approvedAddress, owner, _msgSenderERC721A()))
            if (!isApprovedForAll(owner, msgSender))
                _revert(StakeCallerNotOwnerNorApproved.selector);

        // Calc new ownership, revert if the token is staked.
        _packedOwnerships[tokenId] = _updateOwnershipDataForStaking(oldOwnership, time);

        uint256 nextOwnership = _packedOwnerships[tokenId + 1];
        // Load next ownership slot and update it if needed.
        if (tokenId + 1 < _currentIndex && nextOwnership == 0) {
            _packedOwnerships[tokenId + 1] = oldOwnership;
        }

        // TODO Emit staking event.
    }

    /**
     * @dev It will use both staking strategies to stake multiple tokens.
     * @notice That those arrays args will be decided from front-end based on events.
     */
    function stakeBatchesAndIds(
        uint256[] calldata batchIds,
        uint256[] calldata ids,
        uint32 time
    ) public {
        // NOTE That this procedure can be further optimized.
        // Every time one of those functions is called, lots of
        // redundant data gets `sload`ed again and again, like the
        // contract `_config`.
        uint256 i = 0;
        for (i; i < batchIds.length; i++)
            stakeBatch(batchIds[i], time);
        for (i = 0; i < ids.length; i++)
            stake(ids[i], time);
    }

    // =============================================================
    //                     EXTRA DATA OPERATIONS
    // =============================================================

    /**
     * @dev Returns the message sender (defaults to `msg.sender`).
     *
     * If you are writing GSN compatible contracts, you need to override this function.
     */
    function _msgSenderERC721A() internal view virtual returns (address) {
        return msg.sender;
    }

    /**
     * @dev Converts a uint256 to its ASCII string decimal representation.
     */
    function _toString(uint256 value) internal pure virtual returns (string memory str) {
        assembly {
            // The maximum value of a uint256 contains 78 digits (1 byte per digit), but
            // we allocate 0xa0 bytes to keep the free memory pointer 32-byte word aligned.
            // We will need 1 word for the trailing zeros padding, 1 word for the length,
            // and 3 words for a maximum of 78 digits. Total: 5 * 0x20 = 0xa0.
            let m := add(mload(0x40), 0xa0)
            // Update the free memory pointer to allocate.
            mstore(0x40, m)
            // Assign the `str` to the end.
            str := sub(m, 0x20)
            // Zeroize the slot after the string.
            mstore(str, 0)

            // Cache the end of the memory to calculate the length later.
            let end := str

            // We write the string from rightmost digit to leftmost digit.
            // The following is essentially a do-while loop that also handles the zero case.
            // prettier-ignore
            for { let temp := value } 1 {} {
                str := sub(str, 1)
                // Write the character to the pointer.
                // The ASCII index of the '0' character is 48.
                mstore8(str, add(48, mod(temp, 10)))
                // Keep dividing `temp` until zero.
                temp := div(temp, 10)
                // prettier-ignore
                if iszero(temp) { break }
            }

            let length := sub(end, str)
            // Move the pointer 32 bytes leftwards to make room for the length.
            str := sub(str, 0x20)
            // Store the length.
            mstore(str, length)
        }
    }

    /**
     * @dev For more efficient reverts.
     */
    function _revert(bytes4 errorSelector) internal pure {
        assembly {
            mstore(0x00, errorSelector)
            revert(0x00, 0x04)
        }
    }
}
