// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
// add interface declaration
import "./interfaces.sol";

/*
1. Modify foundry.toml
2. Test forking
3. Add ERC20 interfce
4. Interact with the contract and get:
    - Name
    - Symbol
    - Decimals
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
