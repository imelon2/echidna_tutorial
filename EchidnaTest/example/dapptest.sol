// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

contract Pausable {
    bool is_paused;

    function paused() public {
        is_paused = true;
    }

    function resume() public {
        is_paused = false;
    }
}

contract token is Pausable{
    mapping(address => uint256) public balances;

    constructor() {
        balances[address(0x01)] = 10;
        is_paused = true;
    }

    function transfer(address to, uint256 value) public {
        // require(!is_paused,"FOUNDRY::ASSUME");
        require(!is_paused);

        uint256 initial_balance_from = balances[address(0x01)];
        uint256 initial_balance_to = balances[to];

        balances[address(0x01)] -= value;
        balances[to] += value;

        assert(balances[address(0x01)] <= initial_balance_from);
        assert(balances[to] >= initial_balance_to);
    }
}

contract TestDappTest is token{
    function checkDapp(address to, uint256 value) public {
        transfer(to, value);
    }
}