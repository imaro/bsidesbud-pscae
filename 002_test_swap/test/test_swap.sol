// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
// add interface declaration
import "./interfaces.sol";

/*
1. Add new interfaces needed for the swap:
 - WETH
 - TETHER
 - IUniswapV2Router
2. Impersonate someone by 'vm.startPrank()'
3. get fake many by 'deal'
4. Wrap ETH to WETH
5. config Swap path (what swap to what)
6. Do swap
7. Swap back
*/

contract PSCAE_Test_Class is Test {
    
    IERC20 target = IERC20(address(0x78AEe175f797ca9929083621eb158573D8aaB497));

    function setUp() public {
        // Create a fork (locally) to do whatever we want without paying fees
        vm.createSelectFork("mainnet");
    }

    function testContract() public {
        console.log("Symbol:", target.symbol());
        console.log("Name:", target.name());
        console.log("Decimals:", target.decimals());
    }
}