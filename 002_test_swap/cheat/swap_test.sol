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
    
    IWETH WETH = IWETH(address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2));
    ITETHER TETHER = ITETHER(address(0xdAC17F958D2ee523a2206206994597C13D831ec7));
    // add Uniswap router interface
    IUniswapV2Router router = IUniswapV2Router(payable(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D));
    
    function setUp() public {
        // Create a fork (locally) to do whatever we want without paying fees
        vm.createSelectFork("mainnet");
    }

    function testContract() public {
        // set a new address
        address testAddress = (address(0xdead57A41ffF8eEF7e64fcB7c8445F9a3d294ef2));
        // Impersonation addrtess
        vm.startPrank(testAddress);
        // Address used (msg.origin)
        console.log("My address: ", testAddress);

        // Cheat and get 1 ether
        console.log("-------- BEFORE SWAP ---------");
        deal(testAddress, 1 ether);
        console.log("ETH Balance:", address(testAddress).balance);
        // Wrap ETH to WETH
        WETH.deposit{value:1 ether}();
        console.log("ETH Balance:", address(testAddress).balance);
        // get Balance of address in token !! 
        console.log("WETH Balance:", WETH.balanceOf(address(testAddress)));

        WETH.approve(address(router),type(uint).max);
        address[] memory path = new address[](2);
        path[0] = address(WETH);
        path[1] = address(TETHER);

        // Buy Tether
        router.swapExactTokensForTokens(WETH.balanceOf(address(testAddress)),0,path,address(testAddress),type(uint).max);
        emit log_named_uint("after swap, TETHER amount", TETHER.balanceOf(address(testAddress)));
        uint amount = TETHER.balanceOf(address(testAddress)) / (10 ** TETHER.decimals());
        console.log("after swap, TETHER amount", amount, "USD");
        amount = WETH.balanceOf(address(testAddress)) / (10 ** WETH.decimals());
        emit log_named_uint("after swap, WETH amount", amount);
        console.log("");
        
        console.log("-------- SWAP BACK ---------");
        // Buy back
        TETHER.approve(address(router),type(uint).max);
        path[0] = address(TETHER);
        path[1] = address(WETH);
        // Buy Tether
        router.swapExactTokensForTokens(TETHER.balanceOf(address(testAddress)),0,path,address(testAddress),type(uint).max);
        console.log("-------- AFTER SWAP ---------");
        emit log_named_uint("after swap, TETHER amount", TETHER.balanceOf(address(testAddress)));
        emit log_named_uint("after swap, WETH amount", WETH.balanceOf(address(testAddress)));
        emit log_named_uint("after swap, ETH amount", address(testAddress).balance);
        console.log("");

        // Unwrap ETH
        console.log("-------- AFTER UNWRAP ---------");
        WETH.withdraw(uint(WETH.balanceOf(address(testAddress))));
        emit log_named_uint("after swap, WETH amount", WETH.balanceOf(address(testAddress)));
        emit log_named_uint("after swap, ETH amount", address(testAddress).balance);
    }
}


