// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;
import "@crytic/properties/contracts/util/Hevm.sol";
import "./ERC20.sol";

contract TestPermit {
	IHevm hevm;
	MyToken erc20;
	address OWNER;
	
	constructor() {
		hevm = IHevm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);
		erc20 = new MyToken();

        OWNER = hevm.addr(1);
	}

	// tagging internal
	function getSignature(
        address owner,
        address spender,
        uint256 assetAmount,
        uint256 pk
    ) internal returns (uint8 v, bytes32 r, bytes32 s,bytes32 hashMsg) {
        bytes32 digest = keccak256(
            abi.encodePacked(
                "\x19\x01",
                erc20.DOMAIN_SEPARATOR(),
                keccak256(
                    abi.encode(
                        keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"),
                        owner,
                        spender,
                        assetAmount,
                        erc20.nonces(owner),
                        block.timestamp
                    )
                )
            )
        );
        hashMsg = digest;
        (v, r, s) = hevm.sign(pk, digest); //this gives us OWNER's signature
  }

	function testERC20pertmit() public {
		uint256 amount = 1000;
        erc20.transfer(OWNER, amount);
		uint256 previousOwnerBalance = erc20.balanceOf(OWNER);
        assert(previousOwnerBalance == 1000);

        (uint8 v, bytes32 r, bytes32 s,bytes32 hashMsg) = getSignature(OWNER,address(this),amount,1);
        erc20.permit(OWNER,address(this),amount,block.timestamp+ 1 days,v,r,s);
        erc20.transferFrom(OWNER, address(2), amount);

        uint256 address2Balance = erc20.balanceOf(address(2));
        assert(address2Balance == amount);
	}
}