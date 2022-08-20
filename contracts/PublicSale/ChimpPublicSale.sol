// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract ChimpPublicSale is Ownable {
    using SafeERC20 for IERC20;

    bool public isDepositEnabled;
    bool public isClaimEnabled;

    uint256 public maxPurchaseAmount;
    bytes32 public whiteListRoot;

    uint256 public chimpPrice;
    IERC20 public immutable CHIMP_TOKEN;

    mapping(address => uint256) public participations;

    mapping(address => uint256) public tokensToBeClaimed;

    event onDeposit(uint256 ethAmount, uint256 chimpAmount);
    event onClaimed(uint256 amount);

    constructor(IERC20 _CHIMP_TOKEN,uint256 price,uint256 _maxPurchaseLimit) {
        CHIMP_TOKEN = _CHIMP_TOKEN;
        chimpPrice = price;
        maxPurchaseAmount = _maxPurchaseLimit;
        
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

    function deposit(bytes32[] calldata _merkleProof) public payable {
        require(isDepositEnabled, "Deposit not enabled");

        require(
            isQualifiedForParticipation(msg.sender, _merkleProof),
            "You are not whitelisted"
        );

        uint256 chimpAmount = (msg.value * 1e18) / chimpPrice;

        require(
            tokensToBeClaimed[msg.sender] + chimpAmount <= maxPurchaseAmount,
            "Can't buy more than max purchase limit amount"
        );

        participations[msg.sender] += msg.value;
        tokensToBeClaimed[msg.sender] += chimpAmount;
        emit onDeposit(msg.value, chimpAmount);
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
        require(tokensToBeClaimed[msg.sender] > 0, "Already Claimed");

        uint256 totalChimpsToBeClaimed = tokensToBeClaimed[msg.sender];
        tokensToBeClaimed[msg.sender] = 0;
        CHIMP_TOKEN.safeTransfer(msg.sender, totalChimpsToBeClaimed);

        emit onClaimed(totalChimpsToBeClaimed);
    }
}
