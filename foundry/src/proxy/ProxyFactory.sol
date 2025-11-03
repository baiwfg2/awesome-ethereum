// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {IUpgradeable} from "./IUpgradeable.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title ProxyFactory
 * @dev 代理工厂，管理所有代理合约的创建和升级
 */
contract ProxyFactory is Ownable {
    // 记录所有已部署的代理
    address[] public deployedProxies;

    // 代理地址 => 实现合约类型标识
    mapping(address => string) public proxyTypes;

    event ProxyDeployed(address indexed proxy, address indexed implementation, string proxyType);
    event ProxyUpgraded(address indexed proxy, address indexed newImplementation);

    constructor() Ownable(msg.sender) {}

    /**
     * @dev 部署新的代理合约
     * @param implementation 实现合约地址
     * @param initData 初始化数据
     * @param proxyType 代理类型标识（如 "BoxV1"）
     */
    function deployProxy(
        address implementation,
        bytes memory initData,
        string memory proxyType
    ) external onlyOwner returns (address) {
        ERC1967Proxy proxy = new ERC1967Proxy(implementation, initData);
        address proxyAddress = address(proxy);

        deployedProxies.push(proxyAddress);
        proxyTypes[proxyAddress] = proxyType;

        emit ProxyDeployed(proxyAddress, implementation, proxyType);
        return proxyAddress;
    }

    /**
     * @dev 升级代理合约 - 用户不需要知道具体实现类型！
     * @param proxyAddress 代理合约地址
     * @param newImplementation 新的实现合约地址
     */
    function upgradeProxy(
        address proxyAddress,
        address newImplementation
    ) external onlyOwner {
        // 🎯 关键：工厂知道如何处理升级，用户不需要知道具体类型
        IUpgradeable proxy = IUpgradeable(proxyAddress);
        proxy.upgradeToAndCall(newImplementation, "");

        emit ProxyUpgraded(proxyAddress, newImplementation);
    }

    /**
     * @dev 获取代理的类型
     */
    function getProxyType(address proxyAddress) external view returns (string memory) {
        return proxyTypes[proxyAddress];
    }

    /**
     * @dev 获取所有已部署的代理
     */
    function getAllProxies() external view returns (address[] memory) {
        return deployedProxies;
    }
}