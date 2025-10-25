// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {DropToken} from "../src/DropToken.sol";
import {MerkleAirdrop} from "../src/MerkleAirdrop.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract DeployMerkleAirdrop is Script {

    uint256 private AMOUNT_TO_TRANSFER = 100 * 1e18;
    bytes32 private s_root = 0xc5012f24f659953d0f1388ee980d1e5a518453a21b12a6db2e71feef1286de3c;

    function run() public returns(MerkleAirdrop,DropToken) {
        return deployMerkleAirdrop();
    }

    function deployMerkleAirdrop() public returns (MerkleAirdrop,DropToken){
        vm.startBroadcast();

        DropToken token = new DropToken();
        MerkleAirdrop airdrop = new MerkleAirdrop(s_root, IERC20(address(token)));
        token.mint(token.owner(), AMOUNT_TO_TRANSFER);
        IERC20(token).transfer(address(airdrop), AMOUNT_TO_TRANSFER);
        vm.stopBroadcast();

        return (airdrop, token);
    }

}