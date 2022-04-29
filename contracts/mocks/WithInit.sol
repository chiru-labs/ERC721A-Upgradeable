pragma solidity >=0.7 <0.9;
pragma experimental ABIEncoderV2;

import "../ERC721AUpgradeable.sol";

contract ERC721AUpgradeableWithInit is ERC721AUpgradeable {
    constructor(string memory name_, string memory symbol_) payable initializer {
        __ERC721A_init(name_, symbol_);
    }
}
import "./ERC721AMockUpgradeable.sol";

contract ERC721AMockUpgradeableWithInit is ERC721AMockUpgradeable {
    constructor(string memory name_, string memory symbol_) payable initializer {
        __ERC721AMock_init(name_, symbol_);
    }
}
import "./ERC721AStartTokenIdMockUpgradeable.sol";

contract ERC721AStartTokenIdMockUpgradeableWithInit is ERC721AStartTokenIdMockUpgradeable {
    constructor(
        string memory name_,
        string memory symbol_,
        uint256 startTokenId_
    ) payable initializer {
        __ERC721AStartTokenIdMock_init(name_, symbol_, startTokenId_);
    }
}
import "./StartTokenIdHelperUpgradeable.sol";

contract StartTokenIdHelperUpgradeableWithInit is StartTokenIdHelperUpgradeable {
    constructor(uint256 startTokenId_) payable initializer {
        __StartTokenIdHelper_init(startTokenId_);
    }
}
import "./ERC721AQueryableStartTokenIdMockUpgradeable.sol";

contract ERC721AQueryableStartTokenIdMockUpgradeableWithInit is ERC721AQueryableStartTokenIdMockUpgradeable {
    constructor(
        string memory name_,
        string memory symbol_,
        uint256 startTokenId_
    ) payable initializer {
        __ERC721AQueryableStartTokenIdMock_init(name_, symbol_, startTokenId_);
    }
}
import "./ERC721AQueryableMockUpgradeable.sol";

contract ERC721AQueryableMockUpgradeableWithInit is ERC721AQueryableMockUpgradeable {
    constructor(string memory name_, string memory symbol_) payable initializer {
        __ERC721AQueryableMock_init(name_, symbol_);
    }
}
import "./ERC721AQueryableOwnersExplicitMockUpgradeable.sol";

contract ERC721AQueryableOwnersExplicitMockUpgradeableWithInit is ERC721AQueryableOwnersExplicitMockUpgradeable {
    constructor(string memory name_, string memory symbol_) payable initializer {
        __ERC721AQueryableOwnersExplicitMock_init(name_, symbol_);
    }
}
import "./ERC721AOwnersExplicitMockUpgradeable.sol";

contract ERC721AOwnersExplicitMockUpgradeableWithInit is ERC721AOwnersExplicitMockUpgradeable {
    constructor(string memory name_, string memory symbol_) payable initializer {
        __ERC721AOwnersExplicitMock_init(name_, symbol_);
    }
}
import "./ERC721AOwnersExplicitStartTokenIdMockUpgradeable.sol";

contract ERC721AOwnersExplicitStartTokenIdMockUpgradeableWithInit is ERC721AOwnersExplicitStartTokenIdMockUpgradeable {
    constructor(
        string memory name_,
        string memory symbol_,
        uint256 startTokenId_
    ) payable initializer {
        __ERC721AOwnersExplicitStartTokenIdMock_init(name_, symbol_, startTokenId_);
    }
}
import "./ERC721ABurnableOwnersExplicitMockUpgradeable.sol";

contract ERC721ABurnableOwnersExplicitMockUpgradeableWithInit is ERC721ABurnableOwnersExplicitMockUpgradeable {
    constructor(string memory name_, string memory symbol_) payable initializer {
        __ERC721ABurnableOwnersExplicitMock_init(name_, symbol_);
    }
}
import "./ERC721ABurnableMockUpgradeable.sol";

contract ERC721ABurnableMockUpgradeableWithInit is ERC721ABurnableMockUpgradeable {
    constructor(string memory name_, string memory symbol_) payable initializer {
        __ERC721ABurnableMock_init(name_, symbol_);
    }
}
import "./ERC721ABurnableStartTokenIdMockUpgradeable.sol";

contract ERC721ABurnableStartTokenIdMockUpgradeableWithInit is ERC721ABurnableStartTokenIdMockUpgradeable {
    constructor(
        string memory name_,
        string memory symbol_,
        uint256 startTokenId_
    ) payable initializer {
        __ERC721ABurnableStartTokenIdMock_init(name_, symbol_, startTokenId_);
    }
}
import "./ERC721AGasReporterMockUpgradeable.sol";

contract ERC721AGasReporterMockUpgradeableWithInit is ERC721AGasReporterMockUpgradeable {
    constructor(string memory name_, string memory symbol_) payable initializer {
        __ERC721AGasReporterMock_init(name_, symbol_);
    }
}
import "./ERC721ReceiverMockUpgradeable.sol";

contract ERC721ReceiverMockUpgradeableWithInit is ERC721ReceiverMockUpgradeable {
    constructor(bytes4 retval) payable initializer {
        __ERC721ReceiverMock_init(retval);
    }
}
