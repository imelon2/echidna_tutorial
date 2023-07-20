// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;
import {Order} from "../contracts/Order.sol";
import {OrderRules} from "../contracts/OrderRules.sol";
import {TxForwarder} from "../contracts/TxForwarder.sol";
import {SBTMinter} from "../contracts/SBTMinter.sol";
import {SBT} from "../contracts/SBT/SBT.sol";
import {DKA} from "../contracts/DKA.sol";
import {Treasury} from "../contracts/Treasury.sol";
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
    address constant shipper = 0x2B5AD5c4795c026514f8317c7a215E218DcCD6cF; // PK : 2
    address constant carrier = 0x6813Eb9362372EEF6200f3b1dbC3f819671cBA69; // PK : 3
    
    event LogAddress(address _address);
    event LogSig(uint8 v, bytes32 r, bytes32 s,bytes signature);
    event LogBalance(uint256 balance);

    struct sigVRS {
        uint8 v;
        bytes32 r;
        bytes32 s;
    }

    constructor() {
        hevm = IHevm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

        _TxForwarder = new TxForwarder();
        _OrderRules = new OrderRules();
        _Order = new Order(address(_OrderRules),address(_TxForwarder));
        _SBTMinter = new SBTMinter(address(_OrderRules),address(_Order));
        _ShipperSBT = new SBT(address(_SBTMinter));
        _CarrierSBT = new SBT(address(_SBTMinter));

        _DKA = new DKA(address(_TxForwarder),address(_Order));
        _DKA.transfer(address(shipper),200 ether);
        _DKA.transfer(address(carrier),200 ether);

        _Treasury = new Treasury(address(_DKA));
        _OrderRules.setDKATokenAddress(address(_DKA));
        _OrderRules.setTreasuryAddress(address(_Treasury));
        _OrderRules.setSBTMinterAddress(address(_SBTMinter));
        _OrderRules.setShipperSBTAddress(address(_ShipperSBT));
        _OrderRules.setCarrierSBTAddress(address(_CarrierSBT));

    }


    function getPermitSignature(
        address owner,
        address spender,
        uint256 assetAmount,
        uint256 pk
    ) internal returns (sigVRS memory _sigVRS,bytes32 hashMsg) {
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
        hashMsg = digest;
        (uint8 v, bytes32 r, bytes32 s) = hevm.sign(pk, digest);
        _sigVRS.v = v;
        _sigVRS.r = r;
        _sigVRS.s = s;
    }

    function getOrderSignature(
        Order.OrderSigData memory orderSigData,
        uint pk
    ) internal returns (sigVRS memory _sigVRS,bytes32 hashMsg) {
        bytes32 digest = keccak256(
            abi.encodePacked(
                "\x19\x01",
                _Order.DOMAIN_SEPARATOR(),
                _Order.hashStruct(orderSigData)
        ));
        hashMsg = digest;
        (uint8 v, bytes32 r, bytes32 s) = hevm.sign(pk, digest);
        _sigVRS.v = v;
        _sigVRS.r = r;
        _sigVRS.s = s;
    }


    function test_Order_Price(uint256 price) public {
        require( 0 < price && price <= 2000 ether, "FOUNDRY::ASSUME");
        
        uint256 _orderId = _Order.getOrderId();

        // CreateOrder()
        hevm.prank(shipper);
        _Order.createOrder(shipper,bytes32("departure"),bytes32("destination"),bytes32("weight"),price,0,true,true,"1");

        // create sig
        Order.order memory data = _Order.getOrder(_orderId);
        uint256 reward = 50 ether;

        Order.OrderSigData memory carrierOrderData = Order.OrderSigData(data._orderId,data._shipper,carrier,data._departure,data._destination,data._packageWeight,price,reward,data._collateral,data._expiredDate, _Order.getNonce(_orderId,carrier));
        (sigVRS memory _sigVRS1,) = getOrderSignature(carrierOrderData,3);
        bytes memory carrierOrderSig = concatSig(_sigVRS1.v,_sigVRS1.r,_sigVRS1.s);

        Order.PermitSigData memory carrierPermitData = Order.PermitSigData(carrier,address(_Order),data._collateral,_DKA.nonces(carrier),block.timestamp);
        (sigVRS memory _sigVRS2,) = getPermitSignature(carrier,address(_Order),data._collateral,3);
        bytes memory carrierCollateralSig = concatSig(_sigVRS2.v,_sigVRS2.r,_sigVRS2.s);


        Order.PermitSigData memory shipperPermitData = Order.PermitSigData(shipper,address(_Order),reward,_DKA.nonces(shipper),block.timestamp);
        (sigVRS memory _sigVRS3,) = getPermitSignature(shipper,address(_Order),reward,2);
        bytes memory shipperRewardSig = concatSig(_sigVRS3.v,_sigVRS3.r,_sigVRS3.s);

        // SelectOrder()
        hevm.prank(shipper);
        _Order.selectOrder(_orderId, carrierOrderData, carrierOrderSig,carrierPermitData, carrierCollateralSig,shipperPermitData,shipperRewardSig);

        // create sig for pickOrder
        (sigVRS memory _sigVRS4,) = getOrderSignature(carrierOrderData,2);

        // PickOrder()
        hevm.prank(carrier);
        _Order.pickOrder(_orderId, carrierOrderData, concatSig(_sigVRS4.v,_sigVRS4.r,_sigVRS4.s));

        (sigVRS memory _sigVRS5,) = getOrderSignature(carrierOrderData,2);
        hevm.prank(carrier);
        _Order.completeOrder(_orderId, carrierOrderData, concatSig(_sigVRS5.v,_sigVRS5.r,_sigVRS5.s));


    }

    function concatSig(uint8 v, bytes32 r, bytes32 s) internal pure returns(bytes memory signature) {
        return abi.encodePacked(r,s,v);
    }

    function recover(uint8 v, bytes32 r, bytes32 s,bytes32 hashMsg) internal pure returns(address signer) {
        signer = ecrecover(hashMsg, v, r, s);
    }
}
