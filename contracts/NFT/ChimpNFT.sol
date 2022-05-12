// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "erc721a/contracts/ERC721A.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ChimpNFT is ERC721A, Ownable {
    uint256 public constant MAX_SUPPLY = 1000;
    bytes32 public whitelistedMarkleRoot;
    string public baseURI;
    mapping(address => bool) public nftClaims;

    event onClaimNFT();

    constructor() ERC721A("ChimpNFT", "ChimpNFT") {}

    function setWhitelistedMarkleRoot(bytes32 root) public onlyOwner {
        whitelistedMarkleRoot = root;
    }

    function setBaseURI(string memory uri) public onlyOwner {
        baseURI = uri;
    }

    function isQualifiedForMint(address addr, bytes32[] calldata _merkleProof)
        public
        view
        returns (bool)
    {
        bytes32 leaf = keccak256(abi.encodePacked(addr));
        return MerkleProof.verify(_merkleProof, whitelistedMarkleRoot, leaf);
    }

    function claimNFT(bytes32[] calldata _merkleProof) external {
        require(totalSupply() + 1 <= MAX_SUPPLY, "Max Supply Exceeds");
        require(
            isQualifiedForMint(msg.sender, _merkleProof),
            "Not Whitelisted"
        );
        require(!nftClaims[msg.sender], "Can't Claim Twice");
        nftClaims[msg.sender] = true;
        _safeMint(msg.sender, 1);
        emit onClaimNFT();
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
    }
}
