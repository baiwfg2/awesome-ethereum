// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { Test, console } from "forge-std/Test.sol";

/**
 * @title GasTrackingDemo - Gas 追踪演示合约
 * @dev 演示如何在不同操作中追踪 gas 消耗
 */
contract GasTrackingDemo {
    uint256 public counter;
    mapping(address => uint256) public balances;
    uint256[] public array;

    function simpleOperation() external {
        counter += 1;
    }

    function storageWriteOperation() external {
        balances[msg.sender] = 100;
    }

    function loopOperation(uint256 iterations) external {
        for(uint256 i = 0; i < iterations; i++) {
            counter += 1;
        }
    }

    function arrayPushOperation(uint256 elements) external {
        for(uint256 i = 0; i < elements; i++) {
            array.push(i);
        }
    }

    function complexOperation() external {
        // 多种操作组合
        counter += 1;                    // SSTORE
        balances[msg.sender] = counter;  // SSTORE
        array.push(counter);             // 动态数组扩展
        
        // 一些计算
        uint256 temp = 0;
        for(uint256 i = 0; i < 10; i++) {
            temp += i * counter;
        }
        
        balances[address(this)] = temp;
    }
}

contract GasTrackingTest is Test {
    GasTrackingDemo gasDemo;

    function setUp() public {
        gasDemo = new GasTrackingDemo();
    }

    function testBasicGasTracking() public {
        console.log("=== Basic Gas Tracking Demo ===");
        
        // 1. 简单操作的 gas 消耗
        uint256 gasStart = gasleft();
        gasDemo.simpleOperation();
        uint256 gasEnd = gasleft();
        uint256 gasConsumed = gasStart - gasEnd;
        
        console.log("Simple operation gas consumed:", gasConsumed);
    }

    function testStorageGasTracking() public {
        console.log("=== Storage Operation Gas Tracking ===");
        
        // 2. 存储操作的 gas 消耗
        uint256 gasStart = gasleft();
        gasDemo.storageWriteOperation();
        uint256 gasEnd = gasleft();
        
        console.log("Storage write gas consumed:", gasStart - gasEnd);
        
        // 再次写入相同位置（应该更便宜, see EIP-2200）
        gasStart = gasleft();
        gasDemo.storageWriteOperation();
        gasEnd = gasleft();
        
        console.log("Storage rewrite gas consumed:", gasStart - gasEnd);
    }

    function testLoopGasTracking() public {
        console.log("=== Loop Operation Gas Tracking ===");
        
        // 测试不同循环次数的 gas 消耗
        uint256[] memory iterations = new uint256[](4);
        iterations[0] = 1;
        iterations[1] = 10;
        iterations[2] = 50;
        iterations[3] = 100;
        
        for(uint256 i = 0; i < iterations.length; i++) {
            uint256 gasStart = gasleft();
            gasDemo.loopOperation(iterations[i]);
            uint256 gasEnd = gasleft();
            
            console.log("Loop", iterations[i], "iterations gas:", gasStart - gasEnd);
        }
    }

    function testDetailedGasBreakdown() public {
        console.log("=== Detailed Gas Breakdown ===");
        
        uint256 totalGasStart = gasleft();
        console.log("Transaction start gas:", totalGasStart);
        
        // 步骤 1: 函数调用开销
        uint256 step1Start = gasleft();
        // 模拟函数调用的最小开销
        uint256 step1End = gasleft();
        console.log("Function call overhead:", step1Start - step1End);
        
        // 步骤 2: 存储操作
        uint256 step2Start = gasleft();
        gasDemo.storageWriteOperation();
        uint256 step2End = gasleft();
        console.log("Storage operation gas:", step2Start - step2End);
        
        // 步骤 3: 复杂操作
        uint256 step3Start = gasleft();
        gasDemo.complexOperation();
        uint256 step3End = gasleft();
        console.log("Complex operation gas:", step3Start - step3End);
        
        uint256 totalGasEnd = gasleft();
        console.log("Total gas consumed:", totalGasStart - totalGasEnd);
    }

    function testGasWithRevert() public {
        console.log("=== Gas Tracking with Revert ===");
        
        uint256 gasStart = gasleft();
        
        try this.failingOperation() {
            // 不应该到这里
        } catch {
            uint256 gasEnd = gasleft();
            console.log("Gas consumed before revert:", gasStart - gasEnd);
        }
    }
    
    function failingOperation() external {
        gasDemo.simpleOperation();  // 这会成功
        require(false, "Intentional failure");  // 这会导致 revert
    }

    function testGasWithExternalCalls() public {
        console.log("=== Gas with External Calls ===");
        
        // 部署另一个合约实例
        GasTrackingDemo anotherContract = new GasTrackingDemo();
        
        uint256 gasStart = gasleft();
        anotherContract.simpleOperation();
        uint256 gasEnd = gasleft();
        
        console.log("External call gas:", gasStart - gasEnd);
        
        // 比较内部调用
        gasStart = gasleft();
        gasDemo.simpleOperation();
        gasEnd = gasleft();
        
        console.log("Internal call gas:", gasStart - gasEnd);
    }
}

/**
 * @title 高级 Gas 分析合约
 */
contract AdvancedGasAnalysis is Test {
    
    function testGasInDifferentContexts() public {
        console.log("=== Gas in Different Contexts ===");
        
        // 1. 在普通函数中
        uint256 gasInFunction = this.measureGasInFunction();
        console.log("Gas measured in function:", gasInFunction);
        
        // 2. 在修饰符中
        uint256 gasWithModifier = this.measureGasWithModifier();
        console.log("Gas measured with modifier:", gasWithModifier);
    }
    
    function measureGasInFunction() external returns (uint256) {
        uint256 gasStart = gasleft();
        // 执行一些操作
        uint256 temp = 0;
        for(uint256 i = 0; i < 10; i++) {
            temp += i;
        }
        uint256 gasEnd = gasleft();
        return gasStart - gasEnd;
    }
    
    modifier gasTracker() {
        uint256 gasStart = gasleft();
        _;
        uint256 gasEnd = gasleft();
        console.log("Gas consumed in modifier:", gasStart - gasEnd);
    }
    
    function measureGasWithModifier() external gasTracker returns (uint256) {
        uint256 temp = 0;
        for(uint256 i = 0; i < 10; i++) {
            temp += i;
        }
        return temp;
    }
}