// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.0;

import "./MockERC20Permit.sol";
// import {IHevm} from "./Hevm.sol";
import "@crytic/properties/contracts/util/Hevm.sol";

// interface iHevm {
//     //signs digest with private key sk
//     function sign(uint256 sk, bytes32 digest) external returns (uint8 v, bytes32 r, bytes32 s);
// }

contract TestDepositWithPermit {
    MockERC20Permit asset;
    IHevm hevm;

    event AssertionFailed(string reason);
    event LogBalance(uint256 balanceOwner, uint256 balanceCaller);

    address constant OWNER = 0x2B5AD5c4795c026514f8317c7a215E218DcCD6cF; //address corresponding to private key 0x2

    constructor() {
        hevm = IHevm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);
        asset = new MockERC20Permit("Permit Token", "PMT", 18);
    }

    //helper method to get signature, signs with private key 2
    function getSignature(
        address owner,
        address spender,
        uint256 assetAmount,
        uint256 pk
    // ) internal returns (uint8 v, bytes32 r, bytes32 s) {
    ) internal returns (bytes memory signature) {
        bytes32 digest = keccak256(
            abi.encodePacked(
                "\x19\x01",
                asset.DOMAIN_SEPARATOR(),
                keccak256(
                    abi.encode(
                        keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"),
                        owner,
                        spender,
                        assetAmount,
                        asset.nonces(owner),
                        block.timestamp
                    )
                )
            )
        );
        // (v, r, s) = hevm.sign(2, digest); //this gives us OWNER's signature

                (uint8 r, bytes32 v, bytes32 s) = hevm.sign(pk, digest);
        assembly {
            r := mload(add(signature, 0x20))
            s := mload(add(signature, 0x40))
            v := byte(0, mload(add(signature, 0x60)))
        }
    }
    //helper method to get signature, signs with private key 2
    function getSignatureA(
        address owner,
        address spender,
        uint256 assetAmount
    ) internal returns (bytes32 r, bytes32 s, uint8 v) {
        bytes32 digest = keccak256(
            abi.encodePacked(
                "\x19\x01",
                asset.DOMAIN_SEPARATOR(),
                keccak256(
                    abi.encode(
                        keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"),
                        owner,
                        spender,
                        assetAmount,
                        asset.nonces(owner),
                        block.timestamp
                    )
                )
            )
        );
        // (v, r, s) = hevm.sign(2, digest); //this gives us OWNER's signature

        (v,r,s) = hevm.sign(2, digest);
    }

    // function _split(bytes memory _sig) public pure returns(bytes32 r, bytes32 s, uint8 v) {
    //     require(_sig.length == 65,"invalid signature length");

    //     assembly {
    //         r := mload(add(_sig, 32))
    //         s := mload(add(_sig,64))
    //         v := byte(0,mload(add(_sig,96)))
    //     }
    // }

    function testERC20PermitDeposit() public {
        uint256 amount = 1000; // we'll only consider transfers of up to 1M tokens
        asset.mint(OWNER, amount);

        uint256 previousOwnerBalance = asset.balanceOf(OWNER);
        uint256 previousCallerBalance = asset.balanceOf(address(this));

        emit LogBalance(previousOwnerBalance, previousCallerBalance);
         bytes memory sig1 = getSignature(OWNER, address(this), amount,1);
         bytes memory sig2 = getSignature(OWNER, address(this), amount,2);

        //  return keccak256(abi.encodePacked((sig1))) == keccak256(abi.encodePacked((sig2)));
         assert (keccak256(abi.encodePacked((sig1))) == keccak256(abi.encodePacked(sig2)));
        // (bytes32 r, bytes32 s, uint8 v) = _split(sig);
        // (bytes32 _r, bytes32 _s, uint8 _v) = getSignatureA(OWNER, address(this), amount);
        
        // return r == _r;
        // try asset.permit(OWNER, address(this), amount, block.timestamp, v, r, s) {} catch {
        //     emit AssertionFailed("signature is invalid");
        // }
        // try asset.transferFrom(OWNER, address(this), amount) {} catch {
        //     emit AssertionFailed("transferFrom reverted");
        // }
        // uint256 currentOwnerBalance = asset.balanceOf(OWNER);
        // uint256 currentCallerBalance = asset.balanceOf(address(this));
        // emit LogBalance(currentOwnerBalance, currentCallerBalance);
        // if (currentCallerBalance != previousCallerBalance + amount && currentOwnerBalance != 0) {
        //     emit AssertionFailed("incorrect amount transferred");
        // }
    }
}