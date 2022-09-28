// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IController {
    function isController(address _address) external view returns (bool);
    function addController(address _newWork) external;
}
