// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@crytic/properties/contracts/util/Hevm.sol";
import "@crytic/properties/contracts/util/PropertiesHelper.sol";

contract sig {
    IHevm hevm;

    uint256 constant shipper = 2; // 2
    uint256 constant carrier = 3

    constructor() {
        hevm = IHevm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);
    }
}