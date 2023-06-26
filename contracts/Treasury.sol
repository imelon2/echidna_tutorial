// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Treasury is Ownable {

    address private tokenAddress;

    constructor(address _tokenAddress) {
        tokenAddress=_tokenAddress;
    }

    function getTotalAmount() external view returns(uint256) {
        return IERC20(tokenAddress).balanceOf(address(this));
    }

    function withdraw(address to, uint256 amount) external onlyOwner {
        IERC20(tokenAddress).transfer(to,amount);
    }

}