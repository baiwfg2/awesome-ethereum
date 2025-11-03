// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

/**
 * @title IBox
 * @dev Box合约的业务接口，定义所有业务功能
 */
interface IBox {
    /**
     * @dev 获取存储的值
     */
    function getValue() external view returns (uint256);

    /**
     * @dev 设置存储的值
     * @param newValue 新的值
     */
    function setValue(uint256 newValue) external;

    /**
     * @dev 获取合约版本
     */
    function version() external pure returns (uint256);

    /**
     * @dev 增加值
     */
    function increment() external;

    /**
     * @dev 减少值
     */
    function decrement() external;
}