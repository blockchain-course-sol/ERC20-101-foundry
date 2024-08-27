// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IExerciseSolution is IERC20 {
    function symbol() external view returns (string memory);

    function getToken() external returns (bool);

    function buyToken() external payable returns (bool);

    function isCustomerWhiteListed(
        address customerAddress
    ) external view returns (bool);

    function customerTierLevel(
        address customerAddress
    ) external view returns (uint256);
}
