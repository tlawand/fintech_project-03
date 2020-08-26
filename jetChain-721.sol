pragma solidity ^0.5.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/token/ERC721/ERC721Full.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/drafts/Counters.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/ownership/Ownable.sol";
import "https://gist.githubusercontent.com/MajdT51/c035eaea5302476b263b2c5a38dd2968/raw/7927c818418667a4d1f561d00a5911440b584a6f/AddrArrayLib.sol";
import "./jetChainAuction.sol";

contract flyToken is ERC721Full, Ownable, FlightAuction {
    
    constructor() ERC721Full("flyToken", "FLY") public { }
    address payable marketAddress = msg.sender;

    using Counters for Counters.Counter;
    Counters.Counter token_ids;
    Counters.Counter request_ids;
    Counters.Counter offer_ids;

    address payable clientAddress;
    mapping(address => bool) isClient;

    address payable charterAddress;
    mapping(address => bool) isCharter;
    
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
        require(isCharter[msg.sender] == true, "permission denied");
        _;
    }

    modifier onlyClient() {
        require(isClient[msg.sender] == true, "permission denied");
        _;
    }

    mapping(uint => FlightRequest) public FlightRequests; //consolidate?
    mapping(uint => FlightOffer) public FlightOffers;     //consolidaet?

    event flightRequestEvent(
        uint request_id,
        uint date,
        uint price,
        uint numberOfPassengers,
        string origin,
        string destination
        // string report_uri
    );
    
    event flightConfirmationEvent(
        uint token_id,
        uint date,
        uint price,
        uint numberOfPassengers,
        string origin,
        string destination
        // string report_uri
    );

    event flightOfferEvent(
        uint offer_id,
        uint date,
        uint price,
        uint numberOfPassengers,
        string origin,
        string destination
        // string report_uri
    );

    event cancelFlightOfferEvent(
        uint flight_id,
        string report_uri
    );

    event cancelFlightRequestEvent(
        uint request_id,
        string report_uri
    );

   // client creates flight request
    function createFlightRequest(
        string memory origin,
        string memory destination,
        uint numberOfPassengers,
        uint date,
        string memory token_uri
        )
        public payable returns(uint) {
        request_ids.increment();
        uint request_id = request_ids.current();
        token_ids.increment();
        uint token_id = token_ids.current();

        isClient[msg.sender] = true;
        
        _mint(msg.sender, token_id);
        _setTokenURI(request_id, token_uri);

        FlightRequests[request_id] = FlightRequest(
            origin,
            destination,
            msg.value, //check if correct
            date,
            numberOfPassengers
            );
        emit flightRequestEvent(
            request_id,
            date,
            msg.value,
            numberOfPassengers,
            origin,
            destination
            );

        return request_id;

    }

    // charter creates a flight offer (for empty leg)
    function createFlightOffer(
        string memory origin,
        string memory destination,
        uint numberOfPassengers,
        bool isAuction,
        uint price,
        uint date,
        string memory token_uri
        )
        public returns(uint) {
        offer_ids.increment();
        uint offer_id = offer_ids.current();
        token_ids.increment();
        uint token_id = token_ids.current();
        
        isCharter[msg.sender] = true;
        
        _mint(msg.sender, token_id);
        _setTokenURI(offer_id, token_uri);

        FlightOffers[offer_id] = FlightOffer(
        origin,
        destination,
        price, //check if correct
        isAuction,
        date,
        numberOfPassengers
        );
        emit flightOfferEvent(
            offer_id,
            date,
            price,
            numberOfPassengers,
            origin,
            destination
            );
        if (isAuction==false) {
            return offer_id;
        }
        else {
            // call auction function
            createAuction(offer_id, 1 days);
        }
    }

    // client confirms flight offered by charter
    function confirmFlightOffer() public payable {
        isClient[msg.sender] = true;
        // Do we need :: mapping(address => uint) balances;
        // Should we use a multiplier on the price to pull our fee?
        // balances[msg.sender] -= price;
        // balances[marketAddress] += price;
    }

    // charter accepts client flight request
    function acceptFlightRequest(uint request_id) public {
        // TODO:
        // set charterAddress = msg.sender
        // transfer tokens from client to escrow (?) account
    }

    // client withdraws request for flight
    function withdrawFlightRequest() public onlyClient {
        // TODO:
        // allow client to withdraw flight request
        // transfer tokens back to client
    }

    // charter withdraws offered flight
    function withdrawFlightOffer() public onlyCharter {
        // TODO:
        // allow charter to cancel flight offer
        // any bids by clients need to be revoked and tokens returned
    }

    // client views flights offered
    function flightOffersNumber() public view returns(uint) {
        return offer_ids.current();
    }

    // charter views flight requests
    function flightRequestsNumber() public view returns(uint) {
        return request_ids.current();
    }

//RICKY
    // uint auctionTimeLength;

    mapping(uint => FlightAuction) public auctions;

    function createAuction(uint offer_id, uint auctionTimeLength) internal {
        auctions[offer_id] = new FlightAuction(charterAddress, auctionTimeLength);
    }

    function endAuction(uint offer_id) public onlyCharter {
        FlightAuction auction = auctions[offer_id];
        auction.auctionEnd();
        safeTransferFrom(owner(), auction.highestBidder(), offer_id);
    }

    function auctionEnded(uint offer_id) public view returns(bool) {
        FlightAuction auction = auctions[offer_id];
        return auction.ended();
    }

    // function highestBid(uint offer_id) public view returns(uint) {
    //     FlightAuction auction = auctions[offer_id];
    //     return auction.highestBid();
    // }

    function pendingReturn(uint offer_id, address sender) public view returns(uint) {
        FlightAuction auction = auctions[offer_id];
        return auction.pendingReturn(sender);
    }

    // client bids on flight offered by charter
    function bid(uint offer_id) public payable {
        FlightAuction auction = auctions[offer_id];
        auction.bid.value(msg.value)(msg.sender);
    }

}