// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./ERC20TD.sol";
import "./IExerciseSolution.sol";
import "./IAllInOneSolution.sol";

contract Evaluator {
    error NotTeacher();
    error ExerciseAlreadySubmitted();
    error InvalidERC20();

    mapping(address => bool) public teachers;
    ERC20TD public immutable erc20tdAddress;

    uint256[20] private randomSupplies;
    string[20] private randomTickers;
    uint256 public nextValueStoreRank;

    mapping(address => string) public assignedTicker;
    mapping(address => uint256) public assignedSupply;
    mapping(address => mapping(uint256 => bool)) public exerciseProgression;
    mapping(address => IExerciseSolution) public studentErc20;
    mapping(address => uint256) public ex8Tier1AmountBought;
    mapping(address => bool) public hasBeenPaired;

    event NewRandomTickerAndSupply(string ticker, uint256 supply);
    event ConstructedCorrectly(address erc20Address);

    constructor(ERC20TD _erc20tdAddress) {
        erc20tdAddress = _erc20tdAddress;
        emit ConstructedCorrectly(address(erc20tdAddress));
    }

    receive() external payable {}

    function ex1_getTickerAndSupply() public {
        assignedSupply[msg.sender] =
            randomSupplies[nextValueStoreRank] *
            1000000000000000000;
        assignedTicker[msg.sender] = randomTickers[nextValueStoreRank];

        nextValueStoreRank += 1;
        if (nextValueStoreRank >= 20) {
            nextValueStoreRank = 0;
        }

        // Crediting points
        if (!exerciseProgression[msg.sender][1]) {
            exerciseProgression[msg.sender][1] = true;
            erc20tdAddress.distributeTokens(msg.sender, 1);
        }
    }

    function ex2_testErc20TickerAndSupply() public {
        require(exerciseProgression[msg.sender][1]);

        require(exerciseProgression[msg.sender][0]);

        require(
            _compareStrings(
                assignedTicker[msg.sender],
                studentErc20[msg.sender].symbol()
            ),
            "Incorrect ticker"
        );
        require(
            assignedSupply[msg.sender] ==
                studentErc20[msg.sender].totalSupply(),
            "Incorrect supply"
        );
        require(
            studentErc20[msg.sender].allowance(address(this), msg.sender) == 0,
            "Allowance not implemented or incorrectly set"
        );
        require(
            studentErc20[msg.sender].balanceOf(address(this)) == 0,
            "BalanceOf not implemented or incorrectly set"
        );
        require(
            studentErc20[msg.sender].approve(msg.sender, 10),
            "Approve not implemented"
        );

        // Crediting points
        if (!exerciseProgression[msg.sender][2]) {
            exerciseProgression[msg.sender][2] = true;
            erc20tdAddress.distributeTokens(msg.sender, 2);
        }
    }

    function ex3_testGetToken() public {
        require(
            address(studentErc20[msg.sender]) != address(0),
            "Student ERC20 not registered"
        );

        uint256 initialBalance = studentErc20[msg.sender].balanceOf(
            address(this)
        );

        studentErc20[msg.sender].getToken();

        uint256 finalBalance = studentErc20[msg.sender].balanceOf(
            address(this)
        );

        require(
            initialBalance < finalBalance,
            "Token balance did not increase"
        );

        if (!exerciseProgression[msg.sender][3]) {
            exerciseProgression[msg.sender][3] = true;
            // Distribute points
            erc20tdAddress.distributeTokens(msg.sender, 2);
        }
    }

    function ex4_testBuyToken() public {
        _testBuyToken();

        if (!exerciseProgression[msg.sender][4]) {
            exerciseProgression[msg.sender][4] = true;
            // Distribute points
            erc20tdAddress.distributeTokens(msg.sender, 2);
        }
    }

    function ex5_testDenyListing() public {
        require(
            address(studentErc20[msg.sender]) != address(0),
            "Student ERC20 not registered"
        );

        require(!studentErc20[msg.sender].isCustomerWhiteListed(address(this)));

        bool wasBuyAccepted = true;
        try studentErc20[msg.sender].getToken() returns (bool v) {
            wasBuyAccepted = v;
        } catch {
            // This is executed in case revert() was used.
            wasBuyAccepted = false;
        }

        require(!wasBuyAccepted);

        if (!exerciseProgression[msg.sender][5]) {
            exerciseProgression[msg.sender][5] = true;
            // Distribute points
            erc20tdAddress.distributeTokens(msg.sender, 1);
        }
    }

    function ex6_testAllowListing() public {
        require(
            address(studentErc20[msg.sender]) != address(0),
            "Student ERC20 not registered"
        );
        require(exerciseProgression[msg.sender][5]);

        require(studentErc20[msg.sender].isCustomerWhiteListed(address(this)));

        ex3_testGetToken();

        if (!exerciseProgression[msg.sender][6]) {
            exerciseProgression[msg.sender][6] = true;
            // Distribute points
            erc20tdAddress.distributeTokens(msg.sender, 2);
        }
    }

    function ex7_testDenyListing() public {
        require(
            address(studentErc20[msg.sender]) != address(0),
            "Student ERC20 not registered"
        );

        require(!studentErc20[msg.sender].isCustomerWhiteListed(address(this)));

        require(studentErc20[msg.sender].customerTierLevel(address(this)) == 0);

        bool wasBuyAccepted = true;
        try studentErc20[msg.sender].buyToken{value: 0.0001 ether}() returns (
            bool v
        ) {
            wasBuyAccepted = v;
        } catch {
            wasBuyAccepted = false;
        }

        require(!wasBuyAccepted);

        if (!exerciseProgression[msg.sender][7]) {
            exerciseProgression[msg.sender][7] = true;
            // Distribute points
            erc20tdAddress.distributeTokens(msg.sender, 1);
        }
    }

    function ex8_testTier1Listing() public {
        require(
            address(studentErc20[msg.sender]) != address(0),
            "Student ERC20 not registered"
        );
        require(exerciseProgression[msg.sender][7]);

        require(studentErc20[msg.sender].isCustomerWhiteListed(address(this)));

        require(studentErc20[msg.sender].customerTierLevel(address(this)) == 1);

        ex8Tier1AmountBought[msg.sender] = _testBuyToken();

        if (!exerciseProgression[msg.sender][8]) {
            exerciseProgression[msg.sender][8] = true;
            // Distribute points
            erc20tdAddress.distributeTokens(msg.sender, 2);
        }
    }

    function ex9_testTier2Listing() public {
        require(
            address(studentErc20[msg.sender]) != address(0),
            "Student ERC20 not registered"
        );
        require(exerciseProgression[msg.sender][7]);

        require(studentErc20[msg.sender].isCustomerWhiteListed(address(this)));

        require(studentErc20[msg.sender].customerTierLevel(address(this)) == 2);

        uint256 tier2AmountBought = _testBuyToken();

        require(tier2AmountBought == 2 * ex8Tier1AmountBought[msg.sender]);

        if (!exerciseProgression[msg.sender][9]) {
            exerciseProgression[msg.sender][9] = true;
            // Distribute points
            erc20tdAddress.distributeTokens(msg.sender, 2);
        }
    }

    function ex10_allInOne() public {
        uint256 initialBalance = erc20tdAddress.balanceOf(msg.sender);
        require(initialBalance == 0, "Solution should start with 0 points");

        IAllInOneSolution callerSolution = IAllInOneSolution(msg.sender);
        callerSolution.completeWorkshop();

        uint256 finalBalance = erc20tdAddress.balanceOf(msg.sender);
        uint256 decimals = erc20tdAddress.decimals();
        require(
            finalBalance >= 10 ** decimals * 18,
            "Solution should end with at least than 2 points"
        );

        if (!exerciseProgression[msg.sender][10]) {
            exerciseProgression[msg.sender][10] = true;
            // Distribute points
            erc20tdAddress.distributeTokens(msg.sender, 2);
        }
    }

    function isTeacher() public view returns (bool) {
        return
            erc20tdAddress.hasRole(erc20tdAddress.TEACHER_ROLE(), msg.sender);
    }

    modifier onlyTeachers() {
        require(isTeacher(), "Caller is not a teacher");
        _;
    }

    function submitExercise(IExerciseSolution studentExercise) public {
        if (hasBeenPaired[address(studentExercise)]) {
            revert ExerciseAlreadySubmitted();
        }

        studentErc20[msg.sender] = studentExercise;
        hasBeenPaired[address(studentExercise)] = true;
        if (!exerciseProgression[msg.sender][0]) {
            exerciseProgression[msg.sender][0] = true;
            erc20tdAddress.distributeTokens(msg.sender, 5);
        }
    }

    function _compareStrings(
        string memory a,
        string memory b
    ) internal pure returns (bool) {
        return (keccak256(abi.encodePacked((a))) ==
            keccak256(abi.encodePacked((b))));
    }

    function bytes32ToString(
        bytes32 _bytes32
    ) public pure returns (string memory) {
        uint8 i = 0;
        while (i < 32 && _bytes32[i] != 0) {
            i++;
        }
        bytes memory bytesArray = new bytes(i);
        for (i = 0; i < 32 && _bytes32[i] != 0; i++) {
            bytesArray[i] = _bytes32[i];
        }
        return string(bytesArray);
    }

    function _testBuyToken() internal returns (uint256 firstBuyAmount) {
        require(
            address(studentErc20[msg.sender]) != address(0),
            "Student ERC20 not registered"
        );

        uint256 initialBalance = studentErc20[msg.sender].balanceOf(
            address(this)
        );

        studentErc20[msg.sender].buyToken{value: 0.0001 ether}();

        uint256 intermediateBalance = studentErc20[msg.sender].balanceOf(
            address(this)
        );

        require(
            initialBalance < intermediateBalance,
            "Token balance did not increase"
        );

        firstBuyAmount = intermediateBalance - initialBalance;

        studentErc20[msg.sender].buyToken{value: 0.0003 ether}();

        uint256 finalBalance = studentErc20[msg.sender].balanceOf(
            address(this)
        );

        require(
            intermediateBalance < finalBalance,
            "Token balance did not increase"
        );

        uint256 secondBuyAmount = finalBalance - intermediateBalance;

        require(
            secondBuyAmount > firstBuyAmount,
            "Second buy amount lower than first"
        );
    }

    function readTicker(
        address studentAddres
    ) public view returns (string memory) {
        return assignedTicker[studentAddres];
    }

    function readSupply(address studentAddres) public view returns (uint256) {
        return assignedSupply[studentAddres];
    }

    function setRandomTickersAndSupply(
        uint256[20] memory _randomSupplies,
        string[20] memory _randomTickers
    ) public onlyTeachers {
        randomSupplies = _randomSupplies;
        randomTickers = _randomTickers;
        nextValueStoreRank = 0;
        for (uint i = 0; i < 20; i++) {
            emit NewRandomTickerAndSupply(randomTickers[i], randomSupplies[i]);
        }
    }
}
