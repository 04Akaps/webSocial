// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IliteraryWork {
    function init(
        address _writer,
        bool _free,
        uint256 _price,
        uint256[] calldata _day,
        address _tokenAddress
    ) external;
}
