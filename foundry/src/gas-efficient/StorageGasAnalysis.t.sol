// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { Test, console } from "forge-std/Test.sol";

/**
 * @title StorageGasDemo - 演示 EVM 存储 Gas 机制
 * @dev 详细解释为什么重复写入存储更便宜
 */
contract StorageGasDemo {
    uint256 public value1;
    uint256 public value2;
    mapping(address => uint256) public balances;

    function writeToNewSlot() external {
        value1 = 100;  // 从 0 写入非零值
    }

    function rewriteSameSlot() external {
        value1 = 200;  // 从非零值写入另一个非零值
    }

    function writeToZero() external {
        value1 = 0;    // 从非零值写入 0
    }

    function writeFromZero() external {
        value1 = 300;  // 从 0 写入非零值
    }

    function writeMapping(address user, uint256 amount) external {
        balances[user] = amount;
    }
}

contract StorageGasAnalysis is Test {
    StorageGasDemo demo;

    function setUp() public {
        demo = new StorageGasDemo();
    }

    function testStorageGasCosts() public {
        console.log("=== Storage Gas Cost Analysis ===");
        console.log("");

        // 1. 首次写入（0 -> 非零）- 最贵
        console.log("1. First write (0 -> non-zero):");
        uint256 gasStart = gasleft();
        demo.writeToNewSlot();  // value1: 0 -> 100
        uint256 gasEnd = gasleft();
        uint256 firstWriteGas = gasStart - gasEnd;
        console.log("   Gas consumed:", firstWriteGas);
        console.log("   Operation: SSTORE (cold slot, 0 -> non-zero)");
        console.log("");

        // 2. 重写相同位置（非零 -> 非零）- 便宜很多
        console.log("2. Rewrite same slot (non-zero -> non-zero):");
        gasStart = gasleft();
        demo.rewriteSameSlot();  // value1: 100 -> 200
        gasEnd = gasleft();
        uint256 rewriteGas = gasStart - gasEnd;
        console.log("   Gas consumed:", rewriteGas);
        console.log("   Operation: SSTORE (warm slot, non-zero -> non-zero)");
        console.log("   Savings:", firstWriteGas - rewriteGas, "gas");
        console.log("");

        // 3. 写入零值（非零 -> 0）- 会有 gas 退款
        console.log("3. Write to zero (non-zero -> 0):");
        gasStart = gasleft();
        demo.writeToZero();  // value1: 200 -> 0
        gasEnd = gasleft();
        uint256 writeZeroGas = gasStart - gasEnd;
        console.log("   Gas consumed:", writeZeroGas);
        console.log("   Operation: SSTORE (warm slot, non-zero -> 0)");
        console.log("   Note: This operation gets gas refund!");
        console.log("");

        // 4. 从零写入非零（0 -> 非零）- 又变贵了
        console.log("4. Write from zero (0 -> non-zero):");
        gasStart = gasleft();
        demo.writeFromZero();  // value1: 0 -> 300
        gasEnd = gasleft();
        uint256 fromZeroGas = gasStart - gasEnd;
        console.log("   Gas consumed:", fromZeroGas);
        console.log("   Operation: SSTORE (warm slot, 0 -> non-zero)");
        console.log("");

        console.log("=== Summary ===");
        console.log("First write (0->non-zero):", firstWriteGas, "gas - Most expensive");
        console.log("Rewrite (non-zero->non-zero):", rewriteGas, "gas - Cheapest");
        console.log("Write zero (non-zero->0):", writeZeroGas, "gas - With refund");
        console.log("From zero (0->non-zero):", fromZeroGas, "gas - Expensive again");
    }

    function testMappingGasCosts() public {
        console.log("=== Mapping Gas Cost Analysis ===");
        console.log("");

        address user1 = address(0x1);
        address user2 = address(0x2);

        // 1. 首次写入 mapping 位置
        console.log("1. First mapping write:");
        uint256 gasStart = gasleft();
        demo.writeMapping(user1, 100);
        uint256 gasEnd = gasleft();
        uint256 firstMappingGas = gasStart - gasEnd;
        console.log("   Gas consumed:", firstMappingGas);
        console.log("");

        // 2. 重写同一个 mapping 位置
        console.log("2. Rewrite same mapping slot:");
        gasStart = gasleft();
        demo.writeMapping(user1, 200);
        gasEnd = gasleft();
        uint256 rewriteMappingGas = gasStart - gasEnd;
        console.log("   Gas consumed:", rewriteMappingGas);
        console.log("   Savings:", firstMappingGas - rewriteMappingGas, "gas");
        console.log("");

        // 3. 写入新的 mapping 位置
        console.log("3. Write to new mapping slot:");
        gasStart = gasleft();
        demo.writeMapping(user2, 300);
        gasEnd = gasleft();
        uint256 newMappingGas = gasStart - gasEnd;
        console.log("   Gas consumed:", newMappingGas);
        console.log("   Similar to first write:", newMappingGas, "~=", firstMappingGas);
    }

    function testDetailedStorageOperations() public {
        console.log("=== Detailed Storage Operations ===");
        console.log("");

        // 测试连续多次写入同一位置
        console.log("Multiple writes to same slot:");

        for(uint i = 1; i <= 5; i++) {
            uint256 gasStart = gasleft();
            demo.rewriteSameSlot();
            uint256 gasEnd = gasleft();
            console.log("   Write", i, "gas:", gasStart - gasEnd);
        }
    }

    function testStoragePatterns() public {
        console.log("=== Storage Access Patterns ===");
        console.log("");

        StorageGasDemo demo2 = new StorageGasDemo();

        // 模式 1: 连续写入多个新槽位
        console.log("Pattern 1 - Writing to multiple new slots:");
        uint256 totalGas = 0;

        uint256 gasStart = gasleft();
        demo2.writeToNewSlot();  // slot 1
        uint256 gasEnd = gasleft();
        uint256 slot1Gas = gasStart - gasEnd;
        totalGas += slot1Gas;
        console.log("   Slot 1:", slot1Gas, "gas");

        // 由于这个合约的限制，我们用 mapping 来模拟多个槽位
        gasStart = gasleft();
        demo2.writeMapping(address(0x1), 100);  // mapping slot 1
        gasEnd = gasleft();
        uint256 mapping1Gas = gasStart - gasEnd;
        totalGas += mapping1Gas;
        console.log("   Mapping 1:", mapping1Gas, "gas");

        gasStart = gasleft();
        demo2.writeMapping(address(0x2), 200);  // mapping slot 2
        gasEnd = gasleft();
        uint256 mapping2Gas = gasStart - gasEnd;
        totalGas += mapping2Gas;
        console.log("   Mapping 2:", mapping2Gas, "gas");

        console.log("   Total for new slots:", totalGas, "gas");
        console.log("");

        // 模式 2: 重写已存在的槽位
        console.log("Pattern 2 - Rewriting existing slots:");
        totalGas = 0;

        gasStart = gasleft();
        demo2.rewriteSameSlot();  // rewrite slot 1
        gasEnd = gasleft();
        uint256 rewrite1Gas = gasStart - gasEnd;
        totalGas += rewrite1Gas;
        console.log("   Rewrite slot 1:", rewrite1Gas, "gas");

        gasStart = gasleft();
        demo2.writeMapping(address(0x1), 150);  // rewrite mapping 1
        gasEnd = gasleft();
        uint256 rewriteMapping1Gas = gasStart - gasEnd;
        totalGas += rewriteMapping1Gas;
        console.log("   Rewrite mapping 1:", rewriteMapping1Gas, "gas");

        gasStart = gasleft();
        demo2.writeMapping(address(0x2), 250);  // rewrite mapping 2
        gasEnd = gasleft();
        uint256 rewriteMapping2Gas = gasStart - gasEnd;
        totalGas += rewriteMapping2Gas;
        console.log("   Rewrite mapping 2:", rewriteMapping2Gas, "gas");

        console.log("   Total for rewrites:", totalGas, "gas");
    }
}