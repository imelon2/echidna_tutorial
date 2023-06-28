// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import {Order} from "../contracts/Order.sol";
import {OrderRules} from "../contracts/OrderRules.sol";
import {TxForwarder} from "../contracts/TxForwarder.sol";
import {SBTMinter} from "../contracts/SBTMinter.sol";
import {SBT} from "../contracts/SBT/SBT.sol";
import {DKA} from "../contracts/DKA.sol";
import {Treasury} from "../contracts/Treasury.sol";
// import {IHevm} from "./Hevm.sol";
import "@crytic/properties/contracts/util/Hevm.sol";

contract OrderEchidnaTest {
    TxForwarder _TxForwarder;
    OrderRules _OrderRules;
    Order _Order;
    SBTMinter _SBTMinter;
    SBT _ShipperSBT;
    SBT _CarrierSBT;
    DKA _DKA;
    Treasury _Treasury;

    IHevm hevm;
    address constant shipper = 0x2B5AD5c4795c026514f8317c7a215E218DcCD6cF; // 2
    address constant carrier = 0x6813Eb9362372EEF6200f3b1dbC3f819671cBA69; // 3
    
    constructor() {
        hevm = IHevm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);
        _TxForwarder = new TxForwarder();
        _OrderRules = new OrderRules();
        _Order = new Order(address(_OrderRules),address(_TxForwarder));
        _SBTMinter = new SBTMinter(address(_OrderRules),address(_Order));
        _ShipperSBT = new SBT(address(_SBTMinter));
        _CarrierSBT = new SBT(address(_SBTMinter));

        _DKA = new DKA(address(_TxForwarder),address(_Order));
        _DKA.transfer(address(shipper),20000*10**18);
        _DKA.transfer(address(carrier),20000*10**18);

        _Treasury = new Treasury(address(_DKA));
        _OrderRules.setDKATokenAddress(address(_DKA));
        _OrderRules.setTreasuryAddress(address(_Treasury));
        _OrderRules.setSBTMinterAddress(address(_SBTMinter));
        _OrderRules.setShipperSBTAddress(address(_ShipperSBT));
        _OrderRules.setCarrierSBTAddress(address(_CarrierSBT));
    }

    // function test_check_balance() public {
    //     uint currentBalance = _DKA.balanceOf(address(0x01));
    //     assert(currentBalance == 20000*10**18);
    // }


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
                _DKA.DOMAIN_SEPARATOR(),
                keccak256(
                    abi.encode(
                        keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"),
                        owner,
                        spender,
                        assetAmount,
                        _DKA.nonces(owner),
                        block.timestamp
                    )
                )
            )
        );
        (uint8 r, bytes32 v, bytes32 s) = hevm.sign(pk, digest);
        assembly {
            r := mload(add(signature, 0x20))
            s := mload(add(signature, 0x40))
            v := byte(0, mload(add(signature, 0x60)))
        }
    }

    function getOrderSignature(
        Order.OrderSigData memory orderSigData
    ) internal returns (bytes memory signature) {
        bytes32 digest = keccak256(
            abi.encodePacked(
                // "\x19\x01",
                _Order.DOMAIN_SEPARATOR(),
                _Order.hashStruct(orderSigData)
        ));

        (uint8 r, bytes32 v, bytes32 s) = hevm.sign(3, digest);
        assembly {
            r := mload(add(signature, 0x20))
            s := mload(add(signature, 0x40))
            v := byte(0, mload(add(signature, 0x60)))
        }
    }


    function test_Order_price(bytes32 weight, uint256 price) public {
        uint256 _orderId = _Order.getOrderId();
        _Order.createOrder(shipper,bytes32("1"),bytes32("1"),weight,price,0,true,true,"1");

        Order.order memory data = _Order.getOrder(_orderId);
        uint256 nonce = _Order.getNonce(_orderId,carrier);
        uint256 reward = 100* 10 **18;

        Order.OrderSigData memory carrierOrderData = Order.OrderSigData(data._orderId,data._shipper,carrier,data._departure,data._destination,data._packageWeight,data._price,reward,data._collateral,data._expiredDate,nonce);
        bytes memory carrierOrderSig = getOrderSignature(carrierOrderData);

        Order.PermitSigData memory carrierPermitData = Order.PermitSigData(carrier,address(_Order),data._price,_DKA.nonces(carrier),block.timestamp);
        bytes memory carrierCollateralSig = getSignature(carrier,address(_Order),data._price,3);

        Order.PermitSigData memory shipperPermitData = Order.PermitSigData(shipper,address(_Order),data._price,_DKA.nonces(shipper),block.timestamp);
        bytes memory shipperRewardSig = getSignature(shipper,address(_Order),data._price,2);

        _Order.selectOrder(_orderId, carrierOrderData, carrierOrderSig,carrierPermitData, carrierCollateralSig,shipperPermitData,shipperRewardSig);

        uint256 currentBalance =_DKA.balanceOf(shipper);
        assert(currentBalance == 20000*10**18);
        // _Order.pickOrder(_orderId, shipperOrderData, shipperMsg);
        // _Order.completeOrder(_orderId, receiverOrderData, shipper712Sig);
    }
}