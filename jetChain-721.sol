pragma solidity ^0.5.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/token/ERC721/ERC721Full.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/drafts/Counters.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/ownership/Ownable.sol";
import "https://gist.githubusercontent.com/MajdT51/c035eaea5302476b263b2c5a38dd2968/raw/7927c818418667a4d1f561d00a5911440b584a6f/AddrArrayLib.sol";
import "./jetChainAuction.sol";

contract flyToken is ERC721Full, Ownable {

    constructor() ERC721Full("flyToken", "FLY") public { }

    using Counters for Counters.Counter;
    Counters.Counter token_ids;

    address payable marketAddress = msg.sender;
    // list of client addresses
    // mapping(address => FlightRequest) clientAddresses;
    // list of charter addresses
    address payable clientAddress;
    address payable charterAddress;

    struct FlightRequest {
        string origin;
        string destination;
        uint price; //check if needed
        uint date;
        uint numberOfPassengers;
    }

    struct FlightOffer {
        string origin;
        string destination;
        uint price; //check if needed
        bool isAuction;
        uint date;
        uint numberOfPassengers;
    }

    modifier onlyOwner() {
        require(msg.sender == marketAddress, "permission denied");
        _;
    }

    modifier onlyCharter() {
        require(msg.sender == charterAddress, "permission denied");
        _;
    } //fix

    modifier onlyClient() {
        require(msg.sender == clientAddress, "permission denied");
        _;
    } // fix

    mapping(uint => FlightRequest) public FlightRequests;
    mapping(uint => FlightOffer) public FlightOffers;

    event flightRequest(
        uint token_id,
        uint date,
        uint price,
        uint numberOfPassengers,
        string origin,
        string destination,
        string report_uri
    );
    
    event flightConfirmation(
        uint token_id,
        uint date,
        uint price,
        uint numberOfPassengers,
        string origin,
        string destination,
        string report_uri
    );

    event flightOffer(
        uint token_id,
        uint date,
        uint price,
        uint numberOfPassengers,
        string origin,
        string destination,
        string report_uri
    );

    event cancelFlightOffer(
        uint token_id,
        string report_uri
    );

    event cancelFlightRequest(
        uint token_id,
        string report_uri
    );

   // client creates flight request
    function createFlightRequest(
        address payable clientAddress, //should append msg.sender to list of addresses
        string memory origin,
        string memory destination,
        uint price,
        uint numberOfPassengers,
        uint date,
        string memory token_uri
        )
        public payable returns(uint) {
        token_ids.increment();
        uint token_id = token_ids.current();

        _mint(clientAddress, token_id);
        _setTokenURI(token_id, token_uri);

        FlightRequests[token_id] = FlightRequest(
            origin,
            destination,
            price = msg.value, //check if correct
            date,
            numberOfPassengers
            );

        return token_id;

    }

    // charter creates a flight offer (for empty leg)
    function createFlightOffer(
        address charter,
        string memory origin,
        string memory destination,
        uint numberOfPassengers,
        bool isAuction,
        uint price,
        uint date,
        string memory token_uri
        )
        public returns(uint) {
        // - price to be paid:
        //     - if fixed price --> price in tokens
        //     - if auction:
        //         - set minimum price (optional)
        //         - set max number of bids
        // set charter address to msg.sender (or original address)
        token_ids.increment();
        uint token_id = token_ids.current();

        _mint(charter, token_id);
        _setTokenURI(token_id, token_uri);

        _setTokenURI(token_id, token_uri);

        if (isAuction) {
            FlightOffers[token_id] = FlightOffer(
            origin,
            destination,
            price, //check if correct
            isAuction=false,
            date,
            numberOfPassengers
            );

            return token_id;
        }
        else {
            // call auction function
            createAuction(token_id);
        }

    }

    function createAuction(uint token_id) public {
            // auctions[token_id] = new FlightAuction(charterAddress);
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
