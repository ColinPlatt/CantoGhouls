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

        vm.roll(269);

        vm.startPrank(Bob);
            nft.mint{gas: 25_000_000}();
        vm.stopPrank();

        assertEq(nft.balanceOf(Bob),1);
        assertEq(nft.ownerOf(1), Bob);
        assertEq(nft.totalSupply(),2);
    }

    function testBadMintMoreThanMax() public {
        
        for(uint256 i = 0; i<420; i++) {
            vm.roll(i*100+69);

            vm.startPrank(Alice);
                nft.mint{gas: 25_000_000}();
            vm.stopPrank();
        }

        assertEq(nft.balanceOf(Alice),420);
        assertEq(nft.totalSupply(),420);

        vm.roll(42_069);

        vm.startPrank(Bob);
            vm.expectRevert("Minted out");
            nft.mint{gas: 25_000_000}();
        vm.stopPrank();

        
    }

    function testBadMintNot69Block() public {
        
        vm.roll(70);

        vm.startPrank(Alice);
            vm.expectRevert("Invalid block");
            nft.mint{gas: 25_000_000}();
        vm.stopPrank();

        assertEq(nft.balanceOf(Alice),0);
        assertEq(nft.totalSupply(),0);
    }

    function testBadMintInsufficientGas() public {
        
        vm.roll(69);

        vm.startPrank(Alice);
            vm.expectRevert("You must supply at least 25m gas");
            nft.mint{gas: 24_000_000}();
        vm.stopPrank();

        assertEq(nft.balanceOf(Alice),0);
        assertEq(nft.totalSupply(),0);
    }

    function testBadMintGasPriceLow() public {
        
        vm.roll(69);

        // we send transactions at 169 gwei, so we bump the base fee
        vm.fee(101*1e9);

        vm.startPrank(Alice);
            vm.expectRevert("Tip your validators");
            nft.mint{gas: 25_000_000}();
        vm.stopPrank();

        assertEq(nft.balanceOf(Alice),0);
        assertEq(nft.totalSupply(),0);
    }

    // shouldn't really be an issue due to gas limits, but let's be sure
    function testBadMultipleMintInBlock() public {
        
        vm.roll(169);

        vm.startPrank(Alice);
            nft.mint{gas: 25_000_000}();
        vm.stopPrank();


        // this should fail
        vm.startPrank(Bob);
            vm.expectRevert("Already minted this block");
            nft.mint{gas: 25_000_000}();
        vm.stopPrank();

        assertEq(block.number, 169);

        assertEq(nft.balanceOf(Alice),1);
        assertEq(nft.ownerOf(0),Alice);
        assertEq(nft.balanceOf(Bob),0);
        assertEq(nft.totalSupply(),1);
        
    }
}
