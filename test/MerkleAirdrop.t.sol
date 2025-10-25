// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ZkSyncChainChecker} from "foundry-devops/src/ZkSyncChainChecker.sol";
import {Test, console} from "forge-std/Test.sol";
import {DropToken} from "../src/DropToken.sol";
import {MerkleAirdrop} from "../src/MerkleAirdrop.sol";
import {DeployMerkleAirdrop} from "../script/DeployMerkleAirdrop.s.sol";

contract MerkleAirdropTest is Test, ZkSyncChainChecker {
    DropToken public token;
    MerkleAirdrop public airdrop;

    bytes32 public ROOT = 0xc5012f24f659953d0f1388ee980d1e5a518453a21b12a6db2e71feef1286de3c;
    bytes32 proofOne = 0x0fd7c981d39bece61f7499702bf59b3114a90e66b51ba2c53abdf7b62986c00a;
    bytes32 proofTwo = 0xb772c21179029e79a95e8e7d8ad305b9a41e4f67c1f473543e82b50d09dde476;

    bytes32[] public proof = [proofOne, proofTwo];

    address user;
    uint256 userPrvKey;
    uint256 AMOUNT_TO_CLAIM = 25 * 1e18;
    uint256 AMOUNT_TO_SEND = AMOUNT_TO_CLAIM * 4;
    address gasPayer;

    function setUp() public {
        if (!isZkSyncChain()) {
            DeployMerkleAirdrop deployer = new DeployMerkleAirdrop();
            (airdrop, token) = deployer.deployMerkleAirdrop();
        } else {
            token = new DropToken();
            airdrop = new MerkleAirdrop(ROOT, token);
            token.mint(token.owner(), AMOUNT_TO_SEND);
            token.transfer(address(airdrop), AMOUNT_TO_SEND);
        }
        (user, userPrvKey) = makeAddrAndKey("user");
        gasPayer = makeAddr("gasPayer");
    }

    function testUserCanClaimToken() public {
        uint256 startingBalance = token.balanceOf(user);
        bytes32 digest = airdrop.getMessageHash(user, AMOUNT_TO_CLAIM);

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(userPrvKey, digest);

        vm.prank(gasPayer);
        airdrop.claim(user, AMOUNT_TO_CLAIM, proof, v, r, s);

        uint256 endingBalance = token.balanceOf(user);
        console.log("ending balance", endingBalance);

        assertEq(endingBalance - startingBalance, AMOUNT_TO_CLAIM);
    }
}
