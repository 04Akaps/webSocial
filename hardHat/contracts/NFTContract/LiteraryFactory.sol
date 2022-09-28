// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./customInterface/IliteraryWork.sol";
// import "./customInterface/IController.sol";

import "../utils/Ownable.sol";

import "hardhat/console.sol";

contract LiteraryFactory is Ownable {
    event MakeNewNovel(
        string _workTitle,
        string _workDescription,
        string _category,
        bool _free,
        uint256 _price,
        uint256 _transitionDate
    );

    struct novel {
        address writer;
        address novelAddress;
        string novelTitle;
        string novelDescription;
        uint256 category;
        bool free;
        bool adult;
        uint256[] day;
        uint256 price;
        uint256 transitionDate;
        string imageLink;
    }

    address private basicLiteraryWork;
    address private tokenAddress;

    mapping(bytes32 => bool) private isExisted;
    string[] private category;

    mapping(address => novel) private nftNovelMap;
    mapping(address => novel[]) private userNovelMap;
    novel[] private novelList;

    constructor(
        string[] memory _categoryList,
        address _basicLiteraryWork,
        address _tokenAddress
    ) {
        for (uint256 i = 0; i < _categoryList.length; i++) {
            category.push(_categoryList[i]);
        }

        basicLiteraryWork = _basicLiteraryWork;
        tokenAddress = _tokenAddress;
    }

    receive() external payable {}

    function makeNewNovel(novel calldata _newWork) external returns (address) {
        _isAlreadyExisted(_newWork.novelTitle, _newWork.category);

        console.log(_newWork.novelAddress);
        console.log(_newWork.writer);
        console.log(msg.sender);

        require(
            _newWork.novelAddress == address(0x0) &&
                _newWork.writer == msg.sender,
            "Error : Just Need Dummy Address"
        );

        if (_newWork.free) {
            require(
                _newWork.price == 0,
                "Error : If Free, price must be a zero"
            );
        }

        address newAddress = _createClone(basicLiteraryWork);
        IliteraryWork newLiteraryWork = IliteraryWork(newAddress);

        newLiteraryWork.init(
            msg.sender,
            _newWork.free,
            _newWork.price,
            _newWork.transitionDate,
            _newWork.day,
            tokenAddress
        );

        novel memory newNovel = novel(
            msg.sender,
            newAddress,
            _newWork.novelTitle,
            _newWork.novelDescription,
            _newWork.category,
            _newWork.free,
            _newWork.adult,
            _newWork.day,
            _newWork.price,
            _newWork.transitionDate,
            _newWork.imageLink
        );

        nftNovelMap[newAddress] = newNovel;
        userNovelMap[msg.sender].push(newNovel);
        novelList.push(newNovel);

        emit MakeNewNovel(
            _newWork.novelTitle,
            _newWork.novelDescription,
            category[_newWork.category],
            _newWork.free,
            _newWork.price,
            _newWork.transitionDate
        );

        return address(newLiteraryWork);
    }

    function viewNftNovelMap(address _address)
        external
        view
        returns (novel memory)
    {
        return nftNovelMap[_address];
    }

    function viewTotalNovels() external view returns (novel[] memory) {
        return novelList;
    }

    function viewMyNovelList() external view returns (novel[] memory) {
        return userNovelMap[msg.sender];
    }

    function viewCategorys() external view returns (string[] memory) {
        return category;
    }

    function viewIsExisted(string memory _workTitle)
        public
        view
        returns (bool)
    {
        bytes32 checkByte = keccak256(bytes(_workTitle));

        return isExisted[checkByte];
    }

    function _isAlreadyExisted(string memory _workTitle, uint256 _category)
        internal
    {
        bytes32 checkByte = keccak256(bytes(_workTitle));

        require(!isExisted[checkByte], "Error : Work Title Error");

        require(
            keccak256(bytes(category[_category])) != keccak256((bytes(""))),
            "Error : Not existed Category"
        );

        isExisted[checkByte] = true;
    }

    function _createClone(address target) internal returns (address result) {
        bytes20 targetBytes = bytes20(target);
        assembly {
            let clone := mload(0x40)
            mstore(
                clone,
                0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000
            )
            mstore(add(clone, 0x14), targetBytes)
            mstore(
                add(clone, 0x28),
                0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000
            )
            result := create(0, clone, 0x37)
        }
    }
}
