// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./IERC20.sol";

// Implementing IERC20 Interface
contract SaveERC20 {
    address savingsToken;
    address owner;

    mapping(address => uint256) savings;

    event savingSuccessful(address sender, uint amount);
    event withdrawalSuccessful(address sender, uint _amount);

    constructor(address _savingsToken) {
        savingsToken = _savingsToken;
        owner = msg.sender;
    }

    function deposite(uint _amount) external {
        // sanity check
        require(msg.sender != address(0), "zero address detected");
        require(_amount > 0, "zero amount detected");
        require(
            IERC20(savingsToken).balanceOf(msg.sender) >= _amount,
            "not enough balance"
        );
        require(
            IERC20(savingsToken).transferFrom(
                msg.sender,
                address(this),
                _amount
            ),
            "failed to transfer"
        );

        savings[msg.sender] += _amount;

        emit savingSuccessful(msg.sender, _amount);
    }

    function withdrawal(uint _amount) external {
        //sanity check
        require(msg.sender != address(0), "zero address detected");
        require(_amount > 0, "zero amount detected");

        uint _userSaving = savings[msg.sender];
        require(_userSaving >= _amount, "not enough balance");

        savings[msg.sender] -= _amount;
        IERC20(savingsToken).transfer(msg.sender, _amount);

        emit withdrawalSuccessful(msg.sender, _amount);
    }

    function checkUserBalance(address _user) external view returns (uint) {
        return savings[_user];
    }

    function checkContractBalance() external view returns (uint) {
        return IERC20(savingsToken).balanceOf(address(this));
    }

    function ownerWithdraw(uint _amount) external {
        require(msg.sender == owner, "only owner can withdraw");

        IERC20(savingsToken).transfer(owner, _amount);
    }
}
