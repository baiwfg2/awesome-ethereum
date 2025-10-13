// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import { Test, console } from "forge-std/Test.sol";

/**
 * @title MemoryVsCalldataDemo - 演示 memory 和 calldata 的 gas 差异
 */
contract MemoryVsCalldataDemo {
    uint public total;

    // 使用 memory - 数据会被复制到内存
    function processArrayMemory(uint[] memory data) external returns (uint) {
        uint sum = 0;
        for(uint i = 0; i < data.length; i++) {
            sum += data[i];
        }
        total = sum;
        return sum;
    }

    // 使用 calldata - 直接从调用数据读取
    function processArrayCalldata(uint[] calldata data) external returns (uint) {
        uint sum = 0;
        for(uint i = 0; i < data.length; i++) {
            sum += data[i];
        }
        total = sum;
        return sum;
    }

    // 只读取数组长度 - 测试访问成本
    function getLengthMemory(uint[] memory data) external pure returns (uint) {
        return data.length;
    }

    function getLengthCalldata(uint[] calldata data) external pure returns (uint) {
        return data.length;
    }

    // 只读取第一个元素
    function getFirstElementMemory(uint[] memory data) external pure returns (uint) {
        require(data.length > 0, "Empty array");
        return data[0];
    }

    function getFirstElementCalldata(uint[] calldata data) external pure returns (uint) {
        require(data.length > 0, "Empty array");
        return data[0];
    }

    // 修改数组元素 - 只有 memory 可以修改
    function modifyArrayMemory(uint[] memory data) external pure returns (uint[] memory) {
        for(uint i = 0; i < data.length; i++) {
            data[i] = data[i] * 2;
        }
        return data;
    }

    // calldata 不能修改，所以这个函数会编译失败
    // function modifyArrayCalldata(uint[] calldata data) external pure returns (uint[] memory) {
    //     data[0] = 100; // ❌ 编译错误：Cannot assign to calldata
    // }
}

contract MemoryVsCalldataTest is Test {
    MemoryVsCalldataDemo demo;

    function setUp() public {
        demo = new MemoryVsCalldataDemo();
    }

    function testSmallArrayComparison() public {
        console.log("=== Small Array (10 elements) ===");

        // 创建小数组
        uint[] memory smallArray = new uint[](10);
        for(uint i = 0; i < 10; i++) {
            smallArray[i] = i + 1;
        }

        // 测试 memory 版本
        uint256 gasStart = gasleft();
        demo.processArrayMemory(smallArray);
        uint256 gasEnd = gasleft();
        uint256 memoryGas = gasStart - gasEnd;

        // 测试 calldata 版本
        gasStart = gasleft();
        demo.processArrayCalldata(smallArray);
        gasEnd = gasleft();
        uint256 calldataGas = gasStart - gasEnd;

        console.log("Memory gas:", memoryGas);
        console.log("Calldata gas:", calldataGas);
        console.log("Gas saved:", memoryGas - calldataGas);
        console.log("Percentage saved:", ((memoryGas - calldataGas) * 100) / memoryGas);
    }

    function testMediumArrayComparison() public {
        console.log("=== Medium Array (50 elements) ===");

        // 创建中等数组
        uint[] memory mediumArray = new uint[](50);
        for(uint i = 0; i < 50; i++) {
            mediumArray[i] = i + 1;
        }

        // 测试 memory 版本
        uint256 gasStart = gasleft();
        demo.processArrayMemory(mediumArray);
        uint256 gasEnd = gasleft();
        uint256 memoryGas = gasStart - gasEnd;

        // 测试 calldata 版本
        gasStart = gasleft();
        demo.processArrayCalldata(mediumArray);
        gasEnd = gasleft();
        uint256 calldataGas = gasStart - gasEnd;

        console.log("Memory gas:", memoryGas);
        console.log("Calldata gas:", calldataGas);
        console.log("Gas saved:", memoryGas - calldataGas);
        console.log("Percentage saved:", ((memoryGas - calldataGas) * 100) / memoryGas);
    }

    function testLargeArrayComparison() public {
        console.log("=== Large Array (100 elements) ===");

        // 创建大数组
        uint[] memory largeArray = new uint[](100);
        for(uint i = 0; i < 100; i++) {
            largeArray[i] = i + 1;
        }

        // 测试 memory 版本
        uint256 gasStart = gasleft();
        demo.processArrayMemory(largeArray);
        uint256 gasEnd = gasleft();
        uint256 memoryGas = gasStart - gasEnd;

        // 测试 calldata 版本
        gasStart = gasleft();
        demo.processArrayCalldata(largeArray);
        gasEnd = gasleft();
        uint256 calldataGas = gasStart - gasEnd;

        console.log("Memory gas:", memoryGas);
        console.log("Calldata gas:", calldataGas);
        console.log("Gas saved:", memoryGas - calldataGas);
        console.log("Percentage saved:", ((memoryGas - calldataGas) * 100) / memoryGas);
    }

    function testAccessPatternComparison() public {
        console.log("=== Access Pattern Comparison ===");

        uint[] memory testArray = new uint[](20);
        for(uint i = 0; i < 20; i++) {
            testArray[i] = i * 10;
        }

        // 只获取长度
        console.log("Length access:");
        uint256 gasStart = gasleft();
        demo.getLengthMemory(testArray);
        uint256 gasEnd = gasleft();
        console.log("  Memory:", gasStart - gasEnd);

        gasStart = gasleft();
        demo.getLengthCalldata(testArray);
        gasEnd = gasleft();
        console.log("  Calldata:", gasStart - gasEnd);

        // 只获取第一个元素
        console.log("First element access:");
        gasStart = gasleft();
        demo.getFirstElementMemory(testArray);
        gasEnd = gasleft();
        console.log("  Memory:", gasStart - gasEnd);

        gasStart = gasleft();
        demo.getFirstElementCalldata(testArray);
        gasEnd = gasleft();
        console.log("  Calldata:", gasStart - gasEnd);
    }

    function testModificationCapability() public {
        console.log("=== Modification Capability ===");

        uint[] memory testArray = new uint[](5);
        for(uint i = 0; i < 5; i++) {
            testArray[i] = i + 1;
        }

        console.log("Original array: [1,2,3,4,5]");

        // 只有 memory 可以修改
        uint256 gasStart = gasleft();
        uint[] memory modifiedArray = demo.modifyArrayMemory(testArray);
        uint256 gasEnd = gasleft();

        console.log("Memory modification gas:", gasStart - gasEnd);
        console.log("Modified array: [doubled values]");

        // 验证修改结果
        for(uint i = 0; i < modifiedArray.length; i++) {
            require(modifiedArray[i] == (i + 1) * 2, "Modification failed");
        }
    }
}