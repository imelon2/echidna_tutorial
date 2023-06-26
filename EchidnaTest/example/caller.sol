// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

contract EchidnaTestCaller {

    // Default senders
    address[3] private senders = [
        address(0x10000),
        address(0x20000),
        address(0x30000)
    ];

    address private sender = msg.sender;

    // Pass _sender as input and require msg.sender == _sender
    // to see _sender for counter example
    function setSender(address _sender) external {
        require(_sender == msg.sender);
        sender = msg.sender;
    }

    // Check default senders. Sender should be one of the 3 default accounts.
    function echidna_test_sender() public view returns (bool) {
        for (uint i; i < 3; i++) {
            if (sender == senders[i]) {
                return true;
            }
        }
        return false;
    }
}