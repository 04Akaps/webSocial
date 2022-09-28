// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IERC1155.sol";
import "./IERC1155MetadataURI.sol";

interface IERC1155Full {
    function mint(
        uint256 _id,
        address _user,
        uint256 _amount
    ) external;

    function burn(
        uint256 _id,
        address _user,
        uint256 _amount
    ) external;

    function init(address _writer) external;
}
