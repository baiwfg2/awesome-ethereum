// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import "./IBox.sol";

/**
 * @title IUpgradeable
 * @dev 完整的升级合约接口，包含管理功能和业务功能
 */
interface IUpgradeable is IBox {
    /**
     * @dev 升级合约实现
     * @param newImplementation 新的实现合约地址
     * @param data 升级时要调用的数据（可选）
     */
    function upgradeToAndCall(address newImplementation, bytes calldata data) external payable;

    /**
     * @dev 初始化函数
     */
    function initialize() external;

    /**
     * @dev 获取合约所有者
     */
    function owner() external view returns (address);
}