// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;
import {Order} from "../contracts/Order.sol";
import {OrderRules} from "../contracts/OrderRules.sol";
import {TxForwarder} from "../contracts/TxForwarder.sol";
import {SBTMinter} from "../contracts/SBTMinter.sol";
import {SBT} from "../contracts/SBT/SBT.sol";
import {DKA} from "../contracts/DKA.sol";
import {Treasury} from "../contracts/Treasury.sol";


contract OrderEchidnaTest {
    TxForwarder _TxForwarder;
    OrderRules _OrderRules;
    Order _Order;
    SBTMinter _SBTMinter;
    SBT _ShipperSBT;
    SBT _CarrierSBT;
    DKA _DKA;
    Treasury _Treasury;

    constructor() {
        _TxForwarder = new TxForwarder();
        _OrderRules = new OrderRules();
        _Order = new Order(address(_OrderRules),address(_TxForwarder));
        _SBTMinter = new SBTMinter(address(_OrderRules),address(_Order));
        _ShipperSBT = new SBT(address(_SBTMinter));
        _CarrierSBT = new SBT(address(_SBTMinter));

        _DKA = new DKA(address(_TxForwarder),address(_Order));
        _DKA.transfer(address(0x01),20000*10**18);
        _DKA.transfer(address(0x02),20000*10**18);

        _Treasury = new Treasury(address(_DKA));
        _OrderRules.setDKATokenAddress(address(_DKA));
        _OrderRules.setTreasuryAddress(address(_Treasury));
        _OrderRules.setSBTMinterAddress(address(_SBTMinter));
        _OrderRules.setShipperSBTAddress(address(_ShipperSBT));
        _OrderRules.setCarrierSBTAddress(address(_CarrierSBT));
    }

    function test_check_balance() public {
        uint currentBalance = _DKA.balanceOf(address(0x01));
        assert(currentBalance == 20000*10**18);
    }

    function test_Order_price( bytes32 departure, bytes32 destination, bytes32 weight, uint256 price,
        Order.OrderSigData memory carrierOrderData,
        Order.PermitSigData memory carrierPermitData,
        Order.PermitSigData memory shipperPermitData) public {
        uint256 _orderId = _Order.getOrderId();
        _Order.createOrder(address(0x01),departure,destination,weight,price,0,true,true,"1");
        _Order.selectOrder(_orderId, carrierOrderData, carrierPermitData, shipperPermitData);

        // _Order.pickOrder(_orderId, shipperOrderData, shipperMsg);
        // _Order.completeOrder(_orderId, receiverOrderData, shipper712Sig);
    }
}