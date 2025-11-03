// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {Script} from "forge-std/Script.sol";
//import {IUpgradeable} from "../src/proxy/IUpgradeable.sol";
//import {IBox} from "../src/proxy/IBox.sol";
import {console} from "forge-std/console.sol";
import {DevOpsTools} from "lib/foundry-devops/src/DevOpsTools.sol";
import {BoxV2} from "../src/proxy/BoxV2.sol";

/**
 * @title InteractWithProxy
 * @dev 演示如何通过接口与代理合约交互，而不需要知道具体实现
 */
contract InteractWithUUPSProxy is Script {

    function run() external {
        address mostRecentDeployedProxy = DevOpsTools.get_most_recent_deployment("ERC1967Proxy", block.chainid);

        interactWithBoxV2(mostRecentDeployedProxy);
    }

    function interactWithBoxV2(address proxyAddr) public {
        BoxV2 proxy = BoxV2(proxyAddr);
        vm.startBroadcast();
        uint256 val = proxy.getValue();
        console.log("Value from BoxV2:", val);
        vm.stopBroadcast();
    }

    function interact(address proxyAddress) public {
        // 📱 方式1：使用业务接口 - 用户日常操作
        //IBox box = IBox(proxyAddress);

        // console.log("=== 业务操作 ===");
        // console.log("当前值:", box.getValue());
        // console.log("版本:", box.version());

        // // 业务操作
        // box.setValue(100);
        // console.log("设置后的值:", box.getValue());

        // box.increment();
        // console.log("增加后的值:", box.getValue());

        // // 🔧 方式2：使用完整接口 - 管理员操作
        // IUpgradeable upgradeable = IUpgradeable(proxyAddress);

        // console.log("=== 管理操作 ===");
        // console.log("所有者:", upgradeable.owner());
        // console.log("当前值:", upgradeable.getValue()); // 也可以调用业务函数

        // 升级操作（需要管理员权限）
        // upgradeable.upgradeToAndCall(newImplementation, "");
    }
}