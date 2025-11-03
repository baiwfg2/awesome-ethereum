// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {Script} from "forge-std/Script.sol";
import {ERC1967Utils} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Utils.sol";
import {IUpgradeable} from "./IUpgradeable.sol";

/**
 * @title ProxyManager
 * @dev 通用代理管理器，不需要知道具体实现合约类型
 */
contract ProxyManager {

    /**
     * @dev 通用升级函数 - 完全不需要知道实现合约类型！
     * @param proxyAddress 代理合约地址
     * @param newImplementation 新的实现合约地址
     */
    function upgradeProxy(address proxyAddress, address newImplementation) external {
        // 🎯 方法1：直接使用通用接口
        IUpgradeable proxy = IUpgradeable(proxyAddress);
        proxy.upgradeToAndCall(newImplementation, "");
    }

    /**
     * @dev 获取代理的当前实现地址
     */
    function getImplementation(address proxyAddress) external view returns (address) {
        // 🔍 使用 EIP-1967 标准直接读取存储槽
        return ERC1967Utils.getImplementation();
    }

    /**
     * @dev 检查一个地址是否是代理合约
     */
    function isProxy(address account) external view returns (bool) {
        // 检查是否有实现槽
        bytes32 slot = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;
        bytes32 implementation;
        assembly {
            implementation := sload(slot)
        }
        return implementation != bytes32(0);
    }
}