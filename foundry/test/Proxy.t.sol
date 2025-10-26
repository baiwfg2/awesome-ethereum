// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import { console } from "forge-std/console.sol";
import { Test } from "forge-std/Test.sol";
import { SmallProxy, ImplementationA, ImplementationB } from "../src/proxy/SmallProxy.sol";

contract SmallProxyTest is Test {
    SmallProxy proxy;
    ImplementationA implA;
    ImplementationB implB;

    function setUp() public {
        proxy = new SmallProxy();
        implA = new ImplementationA();
        implB = new ImplementationB();
    }

    function testProxyUpgradeAndFunctionality() public {
        proxy.setImplementation(address(implA));
        // Prepare data to call setValue(42)
        bytes memory data = proxy.getDataToTransact(42);
        // Call the proxy with the data
        (bool success, ) = address(proxy).call(data);
        require(success, "Call to ImplementationA failed");
        uint256 storedValue = proxy.readStorage();
        assertEq(storedValue, 42, "Value should be 42 from ImplementationA");

        // Upgrade to ImplementationB
        proxy.setImplementation(address(implB));
        // Prepare data to call setValue(42)
        data = proxy.getDataToTransact(42);
        (success, ) = address(proxy).call(data);
        require(success, "Call to ImplementationB failed");
        storedValue = proxy.readStorage();
        assertEq(storedValue, 44, "Value should be 44 from ImplementationB");
    }
}