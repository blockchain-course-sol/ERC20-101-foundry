// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "../lib/forge-std/src/Script.sol";
import "../src/ERC20TD.sol";
contract DeployEx is Script {
    ERC20TD public erc20td;
    address public erc20tdAddress;
    mapping(string => address) public deployedContracts;
    string[] public deployedContractsTag;

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("DEPLOYER");
        address deployerAddress = vm.addr(deployerPrivateKey);

        erc20tdAddress = address(0);

        vm.startBroadcast(deployerPrivateKey);

        deployERC20TD();
        deployContracts();
        setTeachers();

        vm.stopBroadcast();

        logDeployments(deployerAddress);
    }

    function deployERC20TD() internal {
        if (erc20tdAddress == address(0)) {
            erc20td = new ERC20TD("TD Token", "TDT", 0);
            erc20tdAddress = address(erc20td);
            console.log("New ERC20TD deployed at:", erc20tdAddress);
        } else {
            erc20td = ERC20TD(erc20tdAddress);
            console.log("Using existing ERC20TD at:", erc20tdAddress);
        }
    }

    function deployContracts() internal {}

    function setTeachers() internal {
        address[] memory teacherAddresses = new address[](
            deployedContractsTag.length
        );
        for (uint i = 0; i < deployedContractsTag.length; i++) {
            teacherAddresses[i] = deployedContracts[deployedContractsTag[i]];
        }
        ERC20TD(erc20tdAddress).setTeachers(teacherAddresses);
    }

    function logDeployments(address deployerAddress) internal view {
        console.log("Deployer address:", deployerAddress);
        console.log("-----------------");
        console.log("ERC20TD address:", erc20tdAddress);

        for (uint i = 0; i < deployedContractsTag.length; i++) {
            console.log(
                string(
                    abi.encodePacked(deployedContractsTag[i], " deployed at:")
                ),
                deployedContracts[deployedContractsTag[i]]
            );
        }
        console.log("-----------------");
    }
}
