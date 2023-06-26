// SPDX-License-Identifier: MIT
pragma solidity ^0.8;
   
contract EchidnaTestTime {
    bool private pass = true;
    uint private createdAt = block.timestamp;

    /*
    test will fail if Echidna can call setFail()
    test will pass otherwise
    */
    function echidna_test_pass() public view returns (bool) {
        return pass;
    }

    function setFail() external {
        /*
        Echidna can call this function if delay <= max block delay
        Otherwise Echidna will not be able to call this function.
        Max block delay can be extended by specifying it in a configuration file.
        */
        uint delay = 7 days;
        require(block.timestamp >= createdAt + delay);
        pass = false;
    }
}