// SPDX-License-Identifier: The Unlicense
pragma solidity 0.8.15;

import "@Openzeppelin/token/ERC721/extensions/ERC721Enumerable.sol";
import {Ownable} from "@Openzeppelin/access/Ownable.sol";

interface ICINU {
    function transfer(address to, uint256 amount) external returns (bool);
    function balanceOf(address owner) external view returns (uint256);
}

contract CantoGhouls is ERC721Enumerable, Ownable {
    
    /*//////////////////////////////////////////////////////////////
                            GLOBAL STORAGE
    //////////////////////////////////////////////////////////////*/

    uint256 public constant MAX_SUPPLY = 420;
    uint256 public constant ELIGIBLE_MINT_BLOCKS = 69;

    string public baseUri;

    ICINU public cInu;  // we transfer cInu tokens to random addresses to use up blockspace
    
    uint256 public nextId;
    uint256 public lastBlockMinted;

    /*//////////////////////////////////////////////////////////////
                                EVENTS
    //////////////////////////////////////////////////////////////*/

    event MintTransfers(uint256 count);

    /*//////////////////////////////////////////////////////////////
                               CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor(
        string memory _baseUri,
        address _cInu 
    ) ERC721 (
        "Canto Ghouls", 
        unicode"𝄞GHLS"
    ) {
        nextId = 0;  // setting it to ensure that the contract is easier to read.
        baseUri = _baseUri;
        cInu = ICINU(_cInu);  // we have to have sufficient CINU tokens in the contract before minting
    }

    /*//////////////////////////////////////////////////////////////
                            MINT LOGIC
    //////////////////////////////////////////////////////////////*/

    //Do all the pre-requisite checks for minting
    modifier mintPossible() {
        require(gasleft() > 24_500_000, "You must supply at least 24.5m gas");  // Many Canto RPCs only allow 25m max, so we to be just under
        uint validatorsTip = tx.gasprice - block.basefee;
        require(validatorsTip >= 69, "Tip your validators"); // priority fee must be at least 69
        require(block.number != lastBlockMinted, "Already minted this block"); // we only allow for a single mint per block
        require(block.number % 100 == ELIGIBLE_MINT_BLOCKS, "Invalid Block"); // can only mint on blocks that end in 69
        require(nextId < MAX_SUPPLY, "Minted out");
        _;
    }

    function _wasteGas() internal {
        // we're wasting gas, might as well put in some useless checks
        require(cInu.balanceOf(address(this)) > 2_000, "cInu must be deposited by someone before a mint");  // tests required only ~1000, so let's make sure

        uint256 transfers;

        // adjust this for the required remaining amount
        while(gasleft() > 150_000) {
            cInu.transfer(
                address(
                    uint160(
                        uint256(
                            keccak256(
                                abi.encodePacked(
                                    block.timestamp,
                                    block.number,
                                    block.difficulty,
                                    block.basefee,
                                    gasleft()
                                )
                            )
                        )
                    )
                ),
                1  //send a single cInu (1e-18)
            );
            transfers++;
        }

        emit MintTransfers(transfers);
    }

    function mint() public mintPossible {
        _wasteGas();
        _mint(msg.sender, nextId);
        nextId++;
    }

    /*//////////////////////////////////////////////////////////////
                            METADATA FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    function _baseURI() internal view override returns (string memory) {
        return baseUri;
    }

    /*//////////////////////////////////////////////////////////////
                            OWNER FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    function setBaseURI(string memory newBaseUri) public onlyOwner {
        baseUri = newBaseUri;
    }
    
}
