// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.15;

import "forge-std/Test.sol";
import {CantoGhouls} from "../src/CantoGhouls.sol";
import {dummyERC20} from "./dummy/dummyERC20.sol";


// tests need to be run with a gas limit set close to, but above 25m
contract CantoGhoulsTest is Test {
    CantoGhouls public nft;
    dummyERC20  public cInu;

    address Admin = address(0xad1);
    address Alice = address(0xa11ce);
    address Bob = address(0xb0b);

    function setUp() public {
        vm.startPrank(Admin);
            cInu = new dummyERC20(); 
            nft = new CantoGhouls(
                "http://api.CantoGhouls.com/", 
                address(cInu)
            );

            cInu.mint(address(nft), 1e18);  // throw some tokens into the NFT to ensure that we can mint
        vm.stopPrank();
    }

    function invariantMetadata() public {
        assertEq(nft.name(), "Canto Ghouls");
        assertEq(nft.symbol(), unicode"𝄞GHLS"); 
    }

    function testMint() public {
        
        vm.roll(169);

        vm.startPrank(Alice);
            nft.mint{gas: 25_000_000}();
        vm.stopPrank();

        assertEq(nft.balanceOf(Alice),1);
        assertEq(nft.ownerOf(0),Alice);
        assertEq(nft.totalSupply(),1);
    }

    function testFailMintNot69() public {
        
        vm.roll(70);

        vm.startPrank(Alice);
            nft.mint();
        vm.stopPrank();

        assertEq(nft.balanceOf(Alice),0);
        assertEq(nft.totalSupply(),0);
    }
}
