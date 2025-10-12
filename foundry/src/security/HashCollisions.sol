// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

// https://scsfg.io/hackers/abi-hash-collisions/

contract RoyaltyRegistry {
    uint256 constant REGULAR_PAYOUT = 0.1 ether;
    uint256 constant PREMIUM_PAYOUT = 1 ether;
    mapping (bytes32 => bool) allowedPayouts;

    function authorize(address[] calldata privileged, address[] calldata regular) external {
        bytes32 payoutKey = keccak256(abi.encodePacked(privileged, regular));
        allowedPayouts[payoutKey] = true;
    }

    function claimRewards(address[] calldata privileged, address[] calldata regular) external {
        bytes32 payoutKey = keccak256(abi.encodePacked(privileged, regular));
        require(allowedPayouts[payoutKey], "Unauthorized claim");
        allowedPayouts[payoutKey] = false;
        _payout(privileged, PREMIUM_PAYOUT);
        _payout(regular, REGULAR_PAYOUT);
    }

    function _payout(address[] calldata users, uint256 reward) internal {
        for(uint i = 0; i < users.length;) {
            (bool success, ) = users[i].call{value: reward}("");
            if (!success) {
                // more code handling pull payment
            }
            unchecked {
                ++i;
            }
        }
    }
}