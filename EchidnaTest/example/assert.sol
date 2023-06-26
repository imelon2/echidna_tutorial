// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;

contract Pausable {
    bool is_paused;

    function paused() public {
        is_paused = true;
    }

    function resume() public {
        is_paused = false;
    }
}

contract TestAssert is Pausable {
    mapping(address => uint256) public balances;

    constructor() {
        balances[address(0x01)] = 10;
        is_paused = true;
    }

    function transfer(address to, uint256 value) public {
        require(!is_paused);

        uint256 initial_balance_from = balances[address(0x01)];
        uint256 initial_balance_to = balances[to];

        balances[address(0x01)] -= value;
        balances[to] += value;

        assert(balances[address(0x01)] <= initial_balance_from);
        assert(balances[to] >= initial_balance_to);
    }
}

contract TestAssert1 {

    // More complex example
    function abs(uint x, uint y) private pure returns (uint) {
        if (x >= y) {
            return x - y;
        }
        return y - x;
    }

    function test_abs(uint x, uint y) external {
        uint z = abs(x, y);
        if (x >= y) {
            assert(z <= x);
        } else {
            assert(z <= y);
        }
    }
}