pragma solidity ^0.5.3;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/token/ERC20/ERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/token/ERC20/ERC20Detailed.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/token/ERC20/ERC20Mintable.sol";

contract flyToken is ERC20, ERC20Detailed, ERC20Mintable {
    constructor(
        // string memory name,
        // string memory symbol,
        // uint initial_supply
    )
        ERC20Detailed("flyToken", "FLY", 18)
        public
    {
        
    }
}

// struct for flights skeleton

// mappings for flights offers and requests
// mappings (?) for client and charter addresses

// check and edit below interface
// interface jetCoin {
//     enum TokenType { Fungible, NonFungible }
//     struct Coin { string obverse; string reverse; }
//     function transfer(address recipient, uint amount) external;
// }

contract jetChain {

    // create modifiers to limit cancelations and confirmations
    address payable owner; // owner of the contract (marketplace company)
    address payable charter; // charter that created flight offer or accepted request
    address payable client; // client that created flight request or bid

    modifier onlyOwner() {
        require(msg.sender == owner, "permission denied");
        _;
    }

    modifier onlyCharter() {
        require(msg.sender == charter, "permission denied");
        _;
    }

    modifier onlyClient() {
        require(msg.sender == client, "permission denied");
        _;
    }

    // client creates flight request
    function createFlightRequest() public payable {
        // TODO:
        // this needs to create a flight request and include:
        // - date of flight
        // - origin
        // - destination
        // - number of passengers
        // - price (using msg.value)
        // set client to msg.sender
        // mint tokens equivalent to msg.amount
    }

    // charter creates a flight offer (for empty leg)
    function createFlightOffer(
        string memory _origin,
        string memory _destination,
        uint memory passengers,
        uint memory price
        ) public {
        // TODO:
        // this needs to create a flight offer and include:
        // - date of flight
        // - origin
        // - destination
        // - number of passengers
        // - price to be paid:
        //     - if fixed price --> price in tokens
        //     - if auction:
        //         - set minimum price (optional)
        //         - set max number of bids
        // set charter address to msg.sender (or original addre)
    }

    // client confirms flight offered by charter
    function confirmFlightOffer() public payable {
        // TODO:
        // set client address to msg.sender (or the original address if this is
        // called by another contract)
        // transfer tokens out of msg.address into escrow (?) account
        // 
    }

    // charter confirms client flight request
    function confirmFlightRequest() public {
        // TODO:
        // set charter = msg.sender
        // transfer tokens from client to escrow (?) account
    }

    // client withdraws request for flight
    function withdrawFlightRequest() public onlyClient {
        // TODO:
        // allow client to withdraw flight request
        // transfer tokens back to client
    }

    // client withdraws bid on flight offer
    function withdrawFlightBid() public onlyClient {
        // TODO:
        // allow client to cancel flight bid
        // return tokens to client
    }

    // charter withdraws offered flight
    function withdrawFlightOffer() public onlyCharter {
        // TODO:
        // allow charter to cancel flight offer
        // any bids by clients need to be revoked and tokens returned
    }

    // client bids on flight offered by charter
    function bidOnFlight() public payable {
        // TODO:
        // allow msg.sender to bidi on flight using msg.value as bid price
    }

    // client views flights offered
    function viewOfferedFlights() public view {
        // TODO:
        // this will be a public function that would list the flight offers
        // available.
        // one implementation might be using a counter to display the number of
        // items in mapping, then a python or JS loop to loop through the mapping
        // elements (since there's no way to list all elements in a mapping, and
        // using loops in solidity consumes a lot of gas)
    }

    // charter views flight requests
    function viewFlightRequests() public view {
        // TODO:
        // this will be a public function that would list the flight requests
        // available.
        // one implementation might be using a counter to display the number of
        // items in mapping, then a python or JS loop to loop through the mapping
        // elements (since there's no way to list all elements in a mapping, and
        // using loops in solidity consumes a lot of gas)
    }

    // client confirms that flight has been completed
    function completeFlight() public onlyClient {
        // TODO:
        // this should allow the client to confirm that the flight has been
        // completed, and transfer the tokens to the charter.
        // only the client is allowed to run this function
    }

    function acceptFlightBid() public onlyCharter {
        // TODO:
        // this should accept the bid on a flight offer
        // only the charter is allowed to run this function
    }

    function withdrawFunds() public {
        // TODO:
        // transfer ETH back to charter or client address and destroy tokens
    }

}