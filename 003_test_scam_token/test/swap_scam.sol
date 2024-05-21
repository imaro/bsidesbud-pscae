// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
// add interface declaration
import "./interfaces.sol";

/*
1. Change TETHER to PROPHET
2. We have to travel in time, since pool is already looted <- find a good TX to have a blocknumber of this
2. Swap token and try to swap back
3. Impersonate some address hardcoded to the contract <- find addres in the contract source code
*/

contract PSCAE_Test_Class is Test {
    
    IWETH WETH = IWETH(address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2));
    IERC20 PROPHET = IERC20(address(0x78AEe175f797ca9929083621eb158573D8aaB497));
    // add Uniswap router interface
    IUniswapV2Router router = IUniswapV2Router(payable(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D));
    
    function setUp() public {
        // Create a fork (locally) to do whatever we want without paying fees
        vm.createSelectFork("mainnet");
    }

    function testContract() public {
        // set a new address
        address testAddress = (address(0xdead57A41ffF8eEF7e64fcB7c8445F9a3d294ef2));
        // Impersonate address
        vm.startPrank(testAddress);
        // Current address used as msg.origin (signer)
        console.log("My address: ", testAddress);

        // Cheat and get 1 ether
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
        path[1] = address(PROPHET);

        // Buy PROPHET
        router.swapExactTokensForTokens(WETH.balanceOf(address(testAddress)),0,path,address(testAddress),type(uint).max);
        emit log_named_uint("after swap, PROPHET amount", PROPHET.balanceOf(address(testAddress)));
        uint amount = PROPHET.balanceOf(address(testAddress)) / (10 ** WETH.decimals());
        emit log_named_uint("after swap, PROPHET amount", amount);
        amount = WETH.balanceOf(address(testAddress)) / (10 ** WETH.decimals());
        emit log_named_uint("after swap, WETH amount", amount);

        console.log("-------- BUY BACK ---------");
        // Buy back
        PROPHET.approve(address(router),type(uint).max);
        path[0] = address(PROPHET);
        path[1] = address(WETH);
        // Buy Tether
        router.swapExactTokensForTokens(PROPHET.balanceOf(address(testAddress)),0,path,address(testAddress),type(uint).max);
        emit log_named_uint("after swap, PROPHET amount", PROPHET.balanceOf(address(testAddress)));
        emit log_named_uint("after swap, WETH amount", WETH.balanceOf(address(testAddress)));
        emit log_named_uint("after swap, ETH amount", address(testAddress).balance);
    }
}
