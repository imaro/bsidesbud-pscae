// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
// add interface declaration
import "./interfaces.sol";


/*
1. Need a generic token interface
2. Read token address from ENV
3. Try to swaps both ways 
4. Test addresses (e.g.: ./script/test.sh 0x3575a80720cfb119347872801d0bd1402e644766):
 - 0x7c851d60b26a4f2a6f2c628ef3b65ed282c54e52 (scam)
 - 0x3575a80720cfb119347872801d0bd1402e644766 (you can sell token)
*/

interface ITOKEN {
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function balanceOf(address owner) external view returns (uint256);

    function approve(address spender, uint256 value) external;
}


library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }
}



contract PSCAE_Test_Class is Test {

    using SafeMath for uint256;
    
    IWETH WETH = IWETH(address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2));
    // add Uniswap router interface
    IUniswapV2Router router = IUniswapV2Router(payable(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D));
    // address TargetAddress;
    CheatCodes cheats = CheatCodes(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);
    // token to test
    ITOKEN token_to_test;
    // set a default amount we would like to use for swap
    uint value = 1 ether;
    // set a new address
    address testAddress = (address(0x3F6ab2E6eC5067A38B637E7ecb51A38C92Ab5862));
    
    function setUp() public {
        // Create a fork (locally) to do whatever we want without paying fees
        vm.createSelectFork("mainnet");
        // Impersonation addrtess
        vm.startPrank(testAddress);
        // Address used (msg.origin)
        console.log("My address: ", testAddress);

        token_to_test = ITOKEN(cheats.envAddress("TOKEN_ADDRESS"));
        console.log("Token to test:", address(token_to_test));
    }

    function testContract() public {
        
        // Cheat and get 1 ether
        deal(testAddress, value);
        // Wrap ETH to WETH
        WETH.deposit{value:value}();
        // get Balance of address in token !! 
        uint beforeTrade = WETH.balanceOf(address(testAddress));
        console.log("WETH Balance:", beforeTrade);

        WETH.approve(address(router),type(uint).max);
        address[] memory path = new address[](2);
        path[0] = address(WETH);
        path[1] = address(token_to_test);

        // get the name of the toke
        string memory symbol = token_to_test.symbol();

        // Buy the token
        router.swapExactTokensForTokens(WETH.balanceOf(address(testAddress)),0,path,address(testAddress),type(uint).max);
        console.log("after swap, '", symbol, "' amount", token_to_test.balanceOf(address(testAddress)));

        console.log("-------- BUY BACK ---------");
        // Buy back
        token_to_test.approve(address(router),type(uint).max);
        path[0] = address(token_to_test);
        path[1] = address(WETH);
        
        // Buy Tether
        router.swapExactTokensForTokens(token_to_test.balanceOf(address(testAddress)),0,path,address(testAddress),type(uint).max);
        emit log_named_uint("after swap, WETH amount", WETH.balanceOf(address(testAddress)));
        
        uint afterTrade = WETH.balanceOf(address(testAddress));
        int256 difference = int256(afterTrade) - int256(beforeTrade);
        // Use a larger factor to keep precision (1e4 for 4 decimal places)
        int256 percentageChange = (difference * 10_000) / int256(beforeTrade);

        emit log_named_int("Diff", difference);
        emit log_named_int("percentageChange", (percentageChange));
    }
}
