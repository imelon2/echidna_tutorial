// SPDX-License-Identifier: MIT
pragma solidity ^0.8;


contract Ownable {
    address public owner = msg.sender;

    modifier onlyOwner() {
        require(msg.sender == owner, "Ownable: Caller is not the owner.");
        _;
    }
}

contract Pausable is Ownable {
    bool private _paused;

    function paused() public view returns (bool) {
        return _paused;
    }

    function pause() public onlyOwner {
        _paused = true;
    }

    function resume() public onlyOwner {
        _paused = false;
    }

    modifier whenNotPaused() {
        require(!_paused, "Pausable: Contract is paused.");
        _;
    }
}

contract Token is Ownable, Pausable {
    mapping(address => uint256) public balances;

    function transfer(address to, uint256 value) public whenNotPaused {
        balances[msg.sender] -= value;
        balances[to] += value;
    }
}

contract MintableToken is Token {
    uint256 public totalMinted;
    uint256 public totalMintable;

    constructor(uint256 totalMintable_) public {
        totalMintable = totalMintable_;
    }

    function mint(uint256 value) public onlyOwner {
        require(uint256(value) + totalMinted < totalMintable);
        totalMinted += uint256(value);

        balances[msg.sender] += value;
    }
}

contract TestToken is MintableToken {
    address echidna = msg.sender;

    // TODO: update the constructor
    constructor() public MintableToken(10001) {
        owner = echidna;
    }

    function echidna_test_balance() public view returns (bool) {
        // TODO: add the property
        return balances[echidna] <= 10000;
    }
}