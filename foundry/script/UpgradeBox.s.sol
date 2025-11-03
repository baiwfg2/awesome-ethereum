// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {Script} from "forge-std/Script.sol";
import {BoxV1} from "../src/proxy/BoxV1.sol";
import {BoxV2} from "../src/proxy/BoxV2.sol";
import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {DevOpsTools} from "lib/foundry-devops/src/DevOpsTools.sol";


contract UpgradeBox is Script {
    function run() external returns (address) {
        address mostRecentDeployedProxy = DevOpsTools.get_most_recent_deployment("ERC1967Proxy", block.chainid);

        vm.startBroadcast();
        BoxV2 boxV2 = new BoxV2();
        vm.stopBroadcast();
        address proxy = upgradeBox(mostRecentDeployedProxy, address(boxV2));
        return proxy;
    }

    function upgradeBox(address proxyAddress, address newBox) public returns (address) {
        vm.startBroadcast();
        // ContractType(address): 这个语法的含义是："将这个地址当作 ContractType 类型的合约来操作"
        BoxV1 proxy = BoxV1(proxyAddress);
        //proxy.upgradeTo(newBox); // 没有此函数了
        // 升级接口现在不在proxy里，所以需要把proxy地址转换成BoxV1类型，然后调用升级接口
        /*
            如果V2里有新的状态需要初始化，就需要在这里会传入
            bytes memory initData = abi.encodeWithSignature("initializeV2()");
            proxy.upgradeToAndCall(newBox, initData);
        */
        proxy.upgradeToAndCall(newBox, "");

        //////////////////////////  一种更优雅的方式： 使用通用接口，不需要知道具体实现合约类型！
        // IUpgradeable proxy = IUpgradeable(proxyAddress);
        // proxy.upgradeToAndCall(newBox, "");

        // 无法这样写，因为 ERC1967Proxy 合约本身没有 upgradeTo 函数
        // ERC1967Proxy(proxyAddress).upgradeTo(newBox);
        vm.stopBroadcast();
        return address(proxy);
    }
}