// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import { Test, console } from "forge-std/Test.sol";

/**
 *
 * @dev 演示如何不断优化sum 的gas使用, see https://www.bilibili.com/video/BV1Pi4y1U7Cu
 */
contract GasOptSum {
    uint public total;
    function sum0(uint[] memory nums) external {
        for (uint i= 0; i < nums.length; i += 1) {
            bool isEven = nums[i] % 2 == 0;
            bool isLessThan99 = nums[i] < 99;
            if (isEven && isLessThan99) {
                total += nums[i];
            }
        }
    }

    // change memory to calldata
    function sum1(uint[] calldata nums) external {
        for (uint i= 0; i < nums.length; i += 1) {
            bool isEven = nums[i] % 2 == 0;
            bool isLessThan99 = nums[i] < 99;
            if (isEven && isLessThan99) {
                total += nums[i];
            }
        }
    }

    function sum2(uint[] calldata nums) external {
        uint _total = total;
        for (uint i= 0; i < nums.length; i += 1) {
            bool isEven = nums[i] % 2 == 0;
            bool isLessThan99 = nums[i] < 99;
            if (isEven && isLessThan99) {
                _total += nums[i]; // read/write memory var，数据量大时应节省不少
            }
        }
        total = _total;
    }

    function sum3(uint[] calldata nums) external {
        uint _total = total;
        for (uint i= 0; i < nums.length; i += 1) {
            // bool isEven = nums[i] % 2 == 0;
            // bool isLessThan99 = nums[i] < 99;
            // 如果左边为 false, 右边就不执行了
            if (nums[i] % 2 == 0 && nums[i] < 99) {
                _total += nums[i];
            }
        }
        total = _total;
    }

    function sum4(uint[] calldata nums) external {
        uint _total = total;
        // 改成 ++i 优化在data1 上不明显 ，但在data6 上有明显效果
        for (uint i= 0; i < nums.length; ++i) {
            if (nums[i] % 2 == 0 && nums[i] < 99) {
                _total += nums[i];
            }
        }
        total = _total;
    }

    function sum5(uint[] calldata nums) external {
        uint _total = total;
        uint len = nums.length; // 当值大的时候，应该有更好的效果
        for (uint i= 0; i < len; ++i) {
            if (nums[i] % 2 == 0 && nums[i] < 99) {
                _total += nums[i];
            }
        }
        total = _total;
    }

    function sum6(uint[] calldata nums) external {
        uint _total = total;
        uint len = nums.length; // 当值大的时候，应该有更好的效果
        for (uint i= 0; i < len; ++i) {
            // 若多次引用存储变量，应该先缓存到内存变量
            uint n = nums[i];
            if (n % 2 == 0 && n < 99) {
                _total += n;
            }
        }
        total = _total;
    }
}

contract GasOptSumTest is Test {
    //GasOptSum sc;

    uint[] private testArray;

    function data1() public {
        /*
        sum0 version: 46611
        sum1 version: 44926
        sum2 version: 44693
        sum3 version: 44388
        sum4 version: 43357
        sum5 version: 43256
        sum6 version: 43131
        */
        testArray = new uint[](6);
        testArray[0] = 1;
        testArray[1] = 2;
        testArray[2] = 3;
        testArray[3] = 4;
        testArray[4] = 5;
        testArray[5] = 100;
    }

    function data2() public {
        // 更多符合条件的偶数 (< 99)
        testArray = new uint[](10);
        testArray[0] = 2;   // ✓ 偶数 < 99
        testArray[1] = 4;   // ✓ 偶数 < 99
        testArray[2] = 6;   // ✓ 偶数 < 99
        testArray[3] = 8;   // ✓ 偶数 < 99
        testArray[4] = 10;  // ✓ 偶数 < 99
        testArray[5] = 12;  // ✓ 偶数 < 99
        testArray[6] = 14;  // ✓ 偶数 < 99
        testArray[7] = 16;  // ✓ 偶数 < 99
        testArray[8] = 18;  // ✓ 偶数 < 99
        testArray[9] = 20;  // ✓ 偶数 < 99
        // 预期总和: 2+4+6+8+10+12+14+16+18+20 = 110
    }

    function data3() public {
        // 全部不符合条件的数据
        testArray = new uint[](8);
        testArray[0] = 1;   // ✗ 奇数
        testArray[1] = 3;   // ✗ 奇数
        testArray[2] = 5;   // ✗ 奇数
        testArray[3] = 7;   // ✗ 奇数
        testArray[4] = 100; // ✗ 偶数但 >= 99
        testArray[5] = 102; // ✗ 偶数但 >= 99
        testArray[6] = 101; // ✗ 奇数且 >= 99
        testArray[7] = 103; // ✗ 奇数且 >= 99
        // 预期总和: 0
    }

    function data4() public {
        // 大数组，混合数据
        testArray = new uint[](20);
        for(uint i = 0; i < 20; i++) {
            if(i % 4 == 0) {
                testArray[i] = i * 2;     // 偶数，大部分 < 99
            } else if(i % 4 == 1) {
                testArray[i] = i * 2 + 1; // 奇数
            } else if(i % 4 == 2) {
                testArray[i] = 100 + i;   // >= 99
            } else {
                testArray[i] = 98 - i;    // 小偶数
            }
        }
    }

    function data5() public {
        // 边界值测试
        testArray = new uint[](12);
        testArray[0] = 0;   // ✓ 偶数，最小值
        testArray[1] = 2;   // ✓ 偶数 < 99
        testArray[2] = 98;  // ✓ 偶数，最大符合条件值
        testArray[3] = 99;  // ✗ 奇数，边界值
        testArray[4] = 100; // ✗ 偶数，刚好不符合
        testArray[5] = 1;   // ✗ 奇数
        testArray[6] = 96;  // ✓ 偶数 < 99
        testArray[7] = 97;  // ✗ 奇数
        testArray[8] = 50;  // ✓ 偶数 < 99
        testArray[9] = 51;  // ✗ 奇数
        testArray[10] = 200; // ✗ 偶数但很大
        testArray[11] = 88;  // ✓ 偶数 < 99
        // 预期总和: 0+2+98+96+50+88 = 334
    }

    /*
    sum0 version: 201992
    sum1 version: 190472
    sum2 version: 186333
    sum3 version: 183784
    sum4 version: 174877
    sum5 version: 174424
    sum6 version: 172907
    */
    function data6() public {
        // 性能压力测试 - 大数组
        testArray = new uint[](50);
        for(uint i = 0; i < 50; i++) {
            // 创建有规律的数据分布
            if(i < 10) {
                testArray[i] = i * 2;        // 0,2,4,6,8,10,12,14,16,18
            } else if(i < 20) {
                testArray[i] = i * 2 + 1;    // 奇数
            } else if(i < 30) {
                testArray[i] = 100 + i;      // 大于99的偶数
            } else if(i < 40) {
                testArray[i] = 90 - (i-30);  // 递减的小偶数
            } else {
                testArray[i] = (i % 2 == 0) ? i : i + 100; // 混合
            }
        }
    }

    function data7() public {
        // 全部符合条件的偶数数组
        testArray = new uint[](15);
        for(uint i = 0; i < 15; i++) {
            testArray[i] = i * 2;  // 0,2,4,6,8,...,28
        }
        // 预期总和: 0+2+4+6+...+28 = 210
    }

    function data8() public {
        // 随机分布的现实数据
        testArray = new uint[](25);
        testArray[0] = 42;   // ✓
        testArray[1] = 17;   // ✗ 奇数
        testArray[2] = 88;   // ✓
        testArray[3] = 91;   // ✗ 奇数
        testArray[4] = 34;   // ✓
        testArray[5] = 156;  // ✗ >= 99
        testArray[6] = 22;   // ✓
        testArray[7] = 75;   // ✗ 奇数
        testArray[8] = 66;   // ✓
        testArray[9] = 99;   // ✗ 奇数
        testArray[10] = 8;   // ✓
        testArray[11] = 103; // ✗ 奇数且 >= 99
        testArray[12] = 54;  // ✓
        testArray[13] = 77;  // ✗ 奇数
        testArray[14] = 12;  // ✓
        testArray[15] = 200; // ✗ >= 99
        testArray[16] = 36;  // ✓
        testArray[17] = 89;  // ✗ 奇数
        testArray[18] = 44;  // ✓
        testArray[19] = 111; // ✗ 奇数且 >= 99
        testArray[20] = 78;  // ✓
        testArray[21] = 23;  // ✗ 奇数
        testArray[22] = 90;  // ✓
        testArray[23] = 45;  // ✗ 奇数
        testArray[24] = 16;  // ✓
        // 符合条件的: 42+88+34+22+66+8+54+12+36+44+78+90+16 = 590
    }

    function setUp() public {
        //data1();
        data6();
    }

    function testGasOptSum0() public {
        GasOptSum sc = new GasOptSum();

        uint256 gasStart = gasleft();
        sc.sum0(testArray);
        uint256 gasEnd = gasleft();
        uint256 gasUsed = gasStart - gasEnd;

        console.log("sum0 version:", gasUsed);
    }

    function testGasOptSum1() public {
        GasOptSum sc = new GasOptSum();

        uint256 gasStart = gasleft();
        sc.sum1(testArray);
        uint256 gasEnd = gasleft();
        uint256 gasUsed = gasStart - gasEnd;

        console.log("sum1 version:", gasUsed);
    }

    function testGasOptSum2() public {
        GasOptSum sc = new GasOptSum();

        uint256 gasStart = gasleft();
        sc.sum2(testArray);
        uint256 gasEnd = gasleft();
        uint256 gasUsed = gasStart - gasEnd;

        console.log("sum2 version:", gasUsed);
    }

    function testGasOptSum3() public {
        GasOptSum sc = new GasOptSum();

        uint256 gasStart = gasleft();
        sc.sum3(testArray);
        uint256 gasEnd = gasleft();
        uint256 gasUsed = gasStart - gasEnd;

        console.log("sum3 version:", gasUsed);
    }

    function testGasOptSum4() public {
        GasOptSum sc = new GasOptSum();

        uint256 gasStart = gasleft();
        sc.sum4(testArray);
        uint256 gasEnd = gasleft();
        uint256 gasUsed = gasStart - gasEnd;

        console.log("sum4 version:", gasUsed);
    }

    function testGasOptSum5() public {
        GasOptSum sc = new GasOptSum();

        uint256 gasStart = gasleft();
        sc.sum5(testArray);
        uint256 gasEnd = gasleft();
        uint256 gasUsed = gasStart - gasEnd;

        console.log("sum5 version:", gasUsed);
    }

    function testGasOptSum6() public {
        GasOptSum sc = new GasOptSum();

        uint256 gasStart = gasleft();
        sc.sum6(testArray);
        uint256 gasEnd = gasleft();
        uint256 gasUsed = gasStart - gasEnd;

        console.log("sum6 version:", gasUsed);
    }
}