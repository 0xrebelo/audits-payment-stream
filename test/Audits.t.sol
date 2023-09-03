// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Test, console2} from "../lib/forge-std/src/Test.sol";
import {Audits} from "../src/Audits.sol";
interface IUSDC {
    function balanceOf(address account) external view returns (uint256);
    function mint(address to, uint256 amount) external;
    function configureMinter(address minter, uint256 minterAllowedAmount) external;
    function masterMinter() external view returns (address);
}

contract AuditsTest is Test {
    Audits public audits;
    IUSDC public usdc;

    address public provider;
    address public client;
    
    function setUp() external {
        provider = address(100);
        client = address(200);
        usdc = IUSDC(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);

        vm.label(provider, "provider");
        vm.label(client, "client"); 
        vm.label(address(usdc), "USDC");

        vm.prank(provider);
        audits = new Audits(10);

        vm.prank(usdc.masterMinter());
        usdc.configureMinter(address(this), type(uint256).max);

        usdc.mint(client, 60000e6);
        assertEq(usdc.balanceOf(client), 60000e6);
    }
}
