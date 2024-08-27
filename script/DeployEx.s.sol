// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "../lib/forge-std/src/Script.sol";
import "../src/ERC20TD.sol";
import "../src/Evaluator.sol";

contract DeployEx is Script {
    ERC20TD public erc20td;
    Evaluator public evaluator;
    address public erc20tdAddress;
    mapping(string => address) public deployedContracts;
    string[] public deployedContractsTag;

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployerAddress = vm.addr(deployerPrivateKey);

        erc20tdAddress = address(0x4aFa9c9e86a249CAaA845261fB3C379e617F9537);

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

    function deployContracts() internal {
        deployEvaluator();
    }

    function deployEvaluator() internal {
        evaluator = new Evaluator(erc20td);
        deployedContracts["Evaluator"] = address(evaluator);
        deployedContractsTag.push("Evaluator");

        (
            uint256[20] memory randomSupplies,
            string[20] memory randomTickers
        ) = generateRandomData();

        evaluator.setRandomTickersAndSupply(randomSupplies, randomTickers);
    }

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
    function generateRandomTicker(
        uint256 length
    ) internal view returns (string memory) {
        bytes
            memory alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz";
        bytes memory ticker = new bytes(length);

        for (uint256 i = 0; i < length; i++) {
            uint256 randomIndex = uint256(
                keccak256(abi.encodePacked(block.timestamp, i))
            ) % alphabet.length;
            ticker[i] = alphabet[randomIndex];
        }

        return string(ticker);
    }
    function generateRandomData()
        internal
        view
        returns (uint256[20] memory, string[20] memory)
    {
        uint256[20] memory randomSupplies;
        string[20] memory randomTickers;

        for (uint256 i = 0; i < 20; i++) {
            randomSupplies[i] =
                uint256(keccak256(abi.encodePacked(block.timestamp, i))) %
                1000000000;

            randomTickers[i] = generateRandomTicker(5);
        }

        return (randomSupplies, randomTickers);
    }
}
