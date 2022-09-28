// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "../customInterface/IController.sol";

contract Controller is IController {
    address private factoryAddress;
    mapping(address => bool) private controller;

    constructor(address _factoryAddress) {
        factoryAddress = _factoryAddress;
    }

    modifier onlyFactoryContract() {
        require(
            msg.sender == factoryAddress,
            "Error : msg.sender Is Not FactoryContract"
        );
        _;
    }

    function addController(address _newWork)
        external
        override
        onlyFactoryContract
    {
        controller[_newWork] = true;
    }

    function isController(address _address)
        external
        view
        override
        returns (bool)
    {
        return controller[_address];
    }
}
