// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../utils/Address.sol";
import "../utils/SafeMath.sol";

import "../Token/interface/IERC20.sol";
import "./interface/ERC1155.sol";

import "./customInterface/IliteraryWork.sol";

contract LiteraryWork is ERC1155, IliteraryWork {
    using Address for address;
    using SafeMath for *;

    event ReviseLiterary(uint256 workId, string newUri);
    event ChangePrice(uint256 price);
    event ChangeFreeStatus(uint256 time);
    event BuyLiterary(uint256 workId, address buyer);
    event WithDraw(uint256 indexed time, uint256 price);

    IERC20 private tokenAddress;

    struct literaryStatusStruct {
        address writer;
        bool free;
        uint256 price;
        uint256[] day;
    }

    struct userStatusStruct {
        uint256[] buyedLiteraryToken;
        uint256[] usedTokenPrice;
        uint256[] buyTime;
        mapping(uint256 => bool) isBuyed;
    }

    struct novel {
        uint256 mintTime;
        uint256 openTime;
    }

    literaryStatusStruct private status;

    mapping(uint256 => novel) private tokenStatus;
    mapping(address => userStatusStruct) private userStatus;

    mapping(uint256 => bool) isExisted;

    bool private alredyInited = false;
    uint256 private tokenIndex = 0;

    event fallBack(uint256 value, address sender);

    receive() external payable {
        emit fallBack(msg.value, msg.sender);
    }

    modifier onlyWriter() {
        require(msg.sender == status.writer, "Error : Not Writer");
        _;
    }

    function init(
        address _writer,
        bool _free,
        uint256 _price,
        uint256[] calldata _days,
        address _tokenAddress
    ) external override {
        require(msg.sender.isContract(), "Error : msg.sender is Not Contract");
        require(!alredyInited, "Error :already inited");

        status.writer = _writer;
        status.free = _free;
        status.price = _price;

        status.day = _days;

        tokenAddress = IERC20(_tokenAddress);
        alredyInited = true;
    }

    function mintBatch(
        uint256[] calldata _amount,
        string[] calldata _tokenUri,
        uint256[] calldata _days
    ) external onlyWriter {
        require(
            _amount.length == _tokenUri.length,
            "Error : FactorValue length Error"
        );

        for (uint256 i = 0; i < _amount.length; i++) {
            mint(_amount[i], _tokenUri[i], _days[i]);
        }
    }

    function mint(
        uint256 _amount,
        string calldata _tokenUri,
        uint256 _days
    ) public onlyWriter {
        uint256 currentTime = _currentTime();

        _setURI(tokenIndex, _tokenUri);
        _mint(msg.sender, tokenIndex, _amount, "");

        isExisted[tokenIndex] = true;

        tokenStatus[tokenIndex].mintTime = currentTime;

        if (!status.free) {
            tokenStatus[tokenIndex].openTime = _days;
        }

        tokenIndex++;
    }

    function reviseLiterary(uint256 _workId, string calldata _tokenUri)
        external
        onlyWriter
    {
        _setURI(_workId, _tokenUri);
        emit ReviseLiterary(_workId, _tokenUri);
    }

    function changePrice(uint256 _price) external onlyWriter {
        status.price = _price;
        emit ChangePrice(_price);
    }

    function changeFreeStatus() external onlyWriter {
        uint256 currentTime = _currentTime();

        for (uint256 i = 0; i < tokenIndex; i++) {
            uint256 literaryFreeTime = tokenStatus[i].openTime;

            if (literaryFreeTime >= currentTime) {
                tokenStatus[i].openTime = 0;
            }
        }

        emit ChangeFreeStatus(currentTime);
    }

    function withDraw() external onlyWriter {
        uint256 value = tokenAddress.balanceOf(address(this));

        tokenAddress.transfer(msg.sender, value);
        payable(msg.sender).transfer(address(this).balance);

        emit WithDraw(block.timestamp, value);
    }

    function buyLiterary(uint256 _workId) external {
        require(isExisted[_workId], "Error : Not Existed Literary");
        require(
            !userStatus[msg.sender].isBuyed[_workId],
            "Error : already Buyed!"
        );
        require(
            tokenStatus[tokenIndex].openTime <= _currentTime(),
            "Error : Free Time Error"
        );

        tokenAddress.transferFrom(msg.sender, address(this), status.price);

        userStatus[msg.sender].buyedLiteraryToken.push(_workId);
        userStatus[msg.sender].usedTokenPrice.push(status.price);
        userStatus[msg.sender].buyTime.push(_currentTime());

        userStatus[msg.sender].isBuyed[_workId] = true;

        emit BuyLiterary(_workId, msg.sender);
    }

    function viewInited() external view returns (bool) {
        return alredyInited;
    }

    function viewTokenIndex() external view returns (uint256) {
        return tokenIndex;
    }

    function viewTokenStatus(uint256 _workId)
        external
        view
        returns (novel memory)
    {
        return tokenStatus[_workId];
    }

    function viewUserisBuyed(address _user, uint256 _workId)
        external
        view
        returns (bool)
    {
        return userStatus[_user].isBuyed[_workId];
    }

    function viewUserStatus(address _user)
        external
        view
        returns (
            uint256[] memory buyedLiteraryList,
            uint256[] memory usedPriceList,
            uint256[] memory buyTime
        )
    {
        userStatusStruct storage buyer = userStatus[_user];
        return (buyer.buyedLiteraryToken, buyer.usedTokenPrice, buyer.buyTime);
    }

    function uri(uint256 _workId) public view override returns (string memory) {
        uint256 openTime = tokenStatus[_workId].openTime;

        if (openTime > _currentTime()) {
            return "";
        }

        return this.uri(_workId);
    }

    function viewWriterStatus()
        external
        view
        returns (literaryStatusStruct memory)
    {
        return status;
    }

    function _currentTime() internal view returns (uint256) {
        return block.timestamp;
    }
}
