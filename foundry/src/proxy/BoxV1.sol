// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

contract BoxV1 is OwnableUpgradeable, UUPSUpgradeable {
//contract BoxV1 is Initializable, OwnableUpgradeable, UUPSUpgradeable {
    uint256 internal value;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        //  防止有人直接在实现合约上调用 initialize, 确保初始化只能通过代理合约进行. Patrick说这样做更 robust
        _disableInitializers();
    }

    // 实现合约的ctor不会针对proxy合约的存储来执行，因此需要把初始化逻辑放在initialize函数中，让proxy调用
    // it's essentially a constructor for proxies
    function initialize() public initializer {
        __Ownable_init(msg.sender);
        //__UUPSUpgradeable_init();
    }

    function getValue() public view returns (uint256) {
        return value;
    }

    function version() public pure returns (uint256) {
        return 1;
    }

    // 暂时不关心谁能升级，留空表示允许任何人升级
    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}
}
