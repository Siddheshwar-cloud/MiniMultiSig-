// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract MiniMultiSig {
    address[] public owners;
    mapping(address => bool) public isOwner;
    uint256 public required;

    struct Tx {
        address to;
        uint256 value;
        uint256 approvals;
        bool executed;
    }

    Tx[] public txs;
    mapping(uint256 => mapping(address => bool)) public approved;

    modifier onlyOwner() {
        require(isOwner[msg.sender], "Not owner");
        _;
    }

    constructor(address[] memory _owners, uint256 _required) {
        require(_owners.length > 0, "No owners");
        require(
            _required > 0 && _required <= _owners.length,
            "Invalid required approvals"
        );

        for (uint256 i = 0; i < _owners.length; i++) {
            address owner = _owners[i];
            require(owner != address(0), "Invalid owner");
            require(!isOwner[owner], "Duplicate owner");

            isOwner[owner] = true;
            owners.push(owner);
        }

        required = _required;
    }

    receive() external payable {}

    function propose(address _to, uint256 _value) external onlyOwner {
        txs.push(Tx({to: _to, value: _value, approvals: 0, executed: false}));
    }

    function approve(uint256 _txId) external onlyOwner {
        Tx storage t = txs[_txId];

        require(!t.executed, "Already executed");
        require(!approved[_txId][msg.sender], "Already approved");

        approved[_txId][msg.sender] = true;
        t.approvals++;

        if (t.approvals >= required) {
            t.executed = true;
            (bool success, ) = t.to.call{value: t.value}("");
            require(success, "ETH transfer failed");
        }
    }

    function getOwners() external view returns (address[] memory) {
        return owners;
    }

    function getTxCount() external view returns (uint256) {
        return txs.length;
    }

    function getTx(
        uint256 _txId
    )
        external
        view
        returns (address to, uint256 value, uint256 approvals, bool executed)
    {
        Tx storage t = txs[_txId];
        return (t.to, t.value, t.approvals, t.executed);
    }
}
