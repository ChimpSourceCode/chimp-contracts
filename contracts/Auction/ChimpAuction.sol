// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract ChimpAuction is Ownable {
    
    bool public isAuctionEnabled ;
    bool public isClaimRefundEnabled;
    uint256 public minBidAmount;
    bytes32 public refundMerkleRoot;

    uint256 public totalBidders;

    mapping(address => uint256) public bids;
    mapping(address => bool) public refundClaimed;

    uint256 public totalBids;

    event onBidPlaced(uint256);
    event onRefundClaimed(uint256);

    function flipAuctionState() public onlyOwner {
        isAuctionEnabled = !isAuctionEnabled;
    }

    function flipClaimRefund() public onlyOwner {
        isClaimRefundEnabled = !isClaimRefundEnabled;
    }

    function setMinBidAmount(uint256 amount) public onlyOwner {
        minBidAmount = amount;
    }

    function placeBid() public payable {
        require(
            msg.value >= minBidAmount,
            "Place bid more than minimum bid amount"
        );
        require(isAuctionEnabled, "Bid Placement not enabled");
        totalBids += 1;
        if(bids[msg.sender]==0){
            totalBidders +=1;
        }
      
        bids[msg.sender] += msg.value;
        emit onBidPlaced(msg.value);
    }

    function withdrawETH(uint256 amount) public onlyOwner {
        payable(msg.sender).transfer(amount);
    }

    function setRefundMerkleRoot(bytes32 root) public onlyOwner {
        refundMerkleRoot = root;
    }

    function isQualifiedForRefund(address addr, bytes32[] calldata _merkleProof)
        public
        view
        returns (bool)
    {
        bytes32 leaf = keccak256(abi.encodePacked(addr));
        return MerkleProof.verify(_merkleProof, refundMerkleRoot, leaf);
    }

    function claimRefund(bytes32[] calldata _merkleProof) public {
        require(isClaimRefundEnabled, "Refund Claim not enabled");

        require(
            isQualifiedForRefund(msg.sender, _merkleProof),
            "You are not whitelisted"
        );

        require(
            !refundClaimed[msg.sender],
            "You have already claimed your refund"
        );

        refundClaimed[msg.sender] = true;
        uint256 amount = bids[msg.sender];
        payable(msg.sender).transfer(amount);
        emit onRefundClaimed(amount);
    }
}
