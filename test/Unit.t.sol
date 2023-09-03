// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;    

import {Setup} from "./Setup.t.sol"; 
    
contract Unit is Setup {
    function testProposeAudit() external {
        vm.prank(provider);
        audits.proposeAudit(client, address(usdc), 60000e6, 6);
    }
}