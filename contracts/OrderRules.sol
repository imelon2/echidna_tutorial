// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;


import "@openzeppelin/contracts/access/Ownable.sol";
contract OrderRules is Ownable {

    //@notice LODIS 플랫폼 수수료 
    uint256 private platformFee;
    uint256 private shipperFee;
    uint256 private carrierFee;
    uint256 private timeExpiredDelayedPick; // 픽업지연 시간
    uint256 private timeExpiredDeliveryFault; // 배송실패 시간
    uint256 private timeExpiredWaitMatching; // 주문등록 후 매칭되기까지 기다리는 최대시간
    uint256 private timeExpiredSpecificMatchingFailDate; // 특정일 매칭전까지 기다리는 최대시간
    uint256 private timeExpiredSpecificDeliveryFailDate; // 특정일 매칭 시, 배송완료까지 최대시간

    address private DKAToken;
    address private SBTMinter;
    address private Treasury;
    address private ShipperSBT;
    address private CarrierSBT;
    address private DefaultSBT;


    constructor() {
        platformFee = 40 ether;
        shipperFee = 10;
        carrierFee = 3;
        timeExpiredDelayedPick = 3 hours;
        timeExpiredDeliveryFault = 4 hours;
        timeExpiredWaitMatching = 30 minutes;

        timeExpiredSpecificMatchingFailDate = 3 hours;
        timeExpiredSpecificDeliveryFailDate = 3 hours;
    }


    // GET() Fee
    function getPlatformFee() external view returns(uint256) {
        return platformFee;
    }
    function getShipperFee() external view returns(uint256) {
        return shipperFee;
    }
    function getCarrierFee() external view returns(uint256) {
        return carrierFee;
    }

    // GET() Expired Time
    function getTimeExpiredDelayedPick() external view returns(uint256) {
        return timeExpiredDelayedPick;
    }
    function getTimeExpiredDeliveryFault() external view returns(uint256) {
        return timeExpiredDeliveryFault;
    }
    function getTimeExpiredWaitMatching() external view returns(uint256) {
        return timeExpiredWaitMatching;
    }
        function getTimeExpiredSpecificMatchingFailDate() external view returns(uint256) {
        return timeExpiredSpecificMatchingFailDate;
    }
    function getTimeExpiredSpecificDeliveryFailDate() external view returns(uint256) {
        return timeExpiredSpecificDeliveryFailDate;
    }

    // GET() Dkargo Contract Address
    function getDKATokenAddress() external view returns(address) {
        return DKAToken;
    }
    function getSBTMinterAddress() external view returns(address) {
        return SBTMinter;
    }
    function getTreasuryAddress() external view returns(address) {
        return Treasury;
    }
    function getShipperSBTAddress() external view returns(address) {
        return ShipperSBT;
    }
    function getCarrierSBTAddress() external view returns(address) {
        return CarrierSBT;
    }
    function getDefaultSBTAddress() external view returns(address) {
        return DefaultSBT;
    }

    // SET() Fee
    function setPlatformFee(uint256 _platformFee) external onlyOwner {
        platformFee = _platformFee;
    }
    function setShipperFee(uint256 _shipperFee) external onlyOwner {
        shipperFee = _shipperFee;
    }
    function setCarrierFee(uint256 _carrierFee) external onlyOwner {
        carrierFee = _carrierFee;
    }

    // SET() Expired Time
    function setTimeExpiredDelayedPick(uint256 _timeExpiredDelayedPick) external onlyOwner {
        timeExpiredDelayedPick = _timeExpiredDelayedPick;
    }
    function setTimeExpiredDeliveryFault(uint256 _timeExpiredDeliveryFault) external onlyOwner {
        timeExpiredDeliveryFault = _timeExpiredDeliveryFault;
    }
    function setTimeExpiredWaitMatching(uint256 _timeExpiredWaitMatching) external onlyOwner {
        timeExpiredWaitMatching = _timeExpiredWaitMatching;
    }
    function setTimeExpiredSpecificMatchingFailDate(uint256 _timeExpiredSpecificMatchingFailDate) external onlyOwner {
        timeExpiredSpecificMatchingFailDate = _timeExpiredSpecificMatchingFailDate;
    }
    function setTimeExpiredSpecificDeliveryFailDate(uint256 _timeExpiredSpecificDeliveryFailDate) external onlyOwner {
        timeExpiredSpecificDeliveryFailDate = _timeExpiredSpecificDeliveryFailDate;
    }

    // SET() Dkargo Contract Address
    function setDKATokenAddress(address _DKAToken) external onlyOwner {
        DKAToken = _DKAToken;
    }
    function setSBTMinterAddress(address _SBTMinter) external onlyOwner {
        SBTMinter = _SBTMinter;
    }
    function setTreasuryAddress(address _Treasury) external onlyOwner {
        Treasury = _Treasury;
    }
    function setShipperSBTAddress(address _ShipperSBT) external onlyOwner {
        ShipperSBT = _ShipperSBT;
    }
    function setCarrierSBTAddress(address _CarrierSBT) external onlyOwner {
        CarrierSBT = _CarrierSBT;
    }
    function setDefaultSBTAddress(address _DefaultSBT) external onlyOwner {
        DefaultSBT = _DefaultSBT;
    }

}