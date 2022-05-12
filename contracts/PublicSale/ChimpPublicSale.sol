// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract ChimpAuction is Ownable {
    using SafeERC20 for IERC20;

    bool public isDepositEnabled;
    bool public isClaimEnabled;

    uint256 public maxPurchaseAmount;
    bytes32 public whiteListRoot;

    uint256 public chimpPrice;
    IERC20 public immutable DEPOSIT_TOKEN;
    IERC20 public immutable CHIMP_TOKEN;

    mapping(address => uint256) public participations;
    mapping(address => bool) public tokensClaimed;

    event onDeposit(uint256 amount);
    event onClaimed(uint256 amount);

    constructor(IERC20 _DEPOSIT_TOKEN, IERC20 _CHIMP_TOKEN) {
        DEPOSIT_TOKEN = _DEPOSIT_TOKEN;
        CHIMP_TOKEN = _CHIMP_TOKEN;
    }

    function flipDepositState() public onlyOwner {
        isDepositEnabled = !isDepositEnabled;
    }

    function flipClaimState() public onlyOwner {
        isClaimEnabled = !isClaimEnabled;
    }

    function setMaxPurchaseAmount(uint256 amount) public onlyOwner {
        maxPurchaseAmount = amount;
    }

    function setChimpPrice(uint256 amount) public onlyOwner {
        chimpPrice = amount;
    }

    function deposit(uint256 amount, bytes32[] calldata _merkleProof) public {
        require(isDepositEnabled, "Deposit not enabled");

        require(
            isQualifiedForParticipation(msg.sender, _merkleProof),
            "You are not whitelisted"
        );

        require(
            amount <= maxPurchaseAmount,
            "Can't buy more than max purchase limit amount"
        );

        DEPOSIT_TOKEN.safeTransferFrom(msg.sender, address(this), amount);

        participations[msg.sender] += amount;
        emit onDeposit(amount);
    }

    function withdrawETH(uint256 amount) public onlyOwner {
        payable(msg.sender).transfer(amount);
    }

    function withdrawTokens(IERC20 _token) public onlyOwner {
        _token.safeTransfer(msg.sender, _token.balanceOf(address(this)));
    }

    function setWhiteListRoot(bytes32 root) public onlyOwner {
        whiteListRoot = root;
    }

    function isQualifiedForParticipation(
        address addr,
        bytes32[] calldata _merkleProof
    ) public view returns (bool) {
        bytes32 leaf = keccak256(abi.encodePacked(addr));
        return MerkleProof.verify(_merkleProof, whiteListRoot, leaf);
    }

    function claimTokens() public {
        require(isClaimEnabled, "Claim not enabled");
        require(
            participations[msg.sender] > 0,
            "Participation amount should be more than zero"
        );

        require(!tokensClaimed[msg.sender], "Already Claimed");

        uint256 totalChimpsToBeClaimed = (participations[msg.sender] * 1e18) /
            chimpPrice;

        CHIMP_TOKEN.safeTransfer(msg.sender, totalChimpsToBeClaimed);
        tokensClaimed[msg.sender] = true;

        emit onClaimed(totalChimpsToBeClaimed);
    }
}
