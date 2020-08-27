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
        address payable clientAddress;
        string origin;
        string destination;
        uint price; //check if needed
        uint date;
        uint numberOfPassengers;
        bool confirmed;
        bool cancelled;
    }

    struct FlightOffer {
        address payable charterAddress;
        string origin;
        string destination;
        uint price; //check if needed
        bool isAuction;
        uint date;
        uint numberOfPassengers;
        bool sold;
        bool cancelled;
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

    event flightCancellationEvent(
        uint flight_id,
        bool cancelled
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
            msg.sender,
            origin,
            destination,
            msg.value, //check if correct
            date,
            numberOfPassengers,
            false,
            false
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
            msg.sender,
            origin,
            destination,
            price, //check if correct
            isAuction,
            date,
            numberOfPassengers,
            false,
            false
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
    function confirmFlightOffer(uint offer_id) public payable {
        isClient[msg.sender] = true;
        FlightOffers[offer_id].charterAddress.transfer(msg.value);
        FlightOffers[offer_id].sold = true;
        
        emit flightConfirmationEvent(
            offer_id,
            FlightOffers[offer_id].date,
            FlightOffers[offer_id].price,
            FlightOffers[offer_id].numberOfPassengers,
            FlightOffers[offer_id].origin,
            FlightOffers[offer_id].destination
        );
    }

    // charter accepts client flight request
    function acceptFlightRequest(uint request_id) public payable {
        isCharter[msg.sender] = true;
        msg.sender.transfer(msg.value);
        FlightRequests[request_id].confirmed = true;
        
        emit flightConfirmationEvent(
            request_id,
            FlightRequests[request_id].date,
            FlightRequests[request_id].price,
            FlightRequests[request_id].numberOfPassengers,
            FlightRequests[request_id].origin,
            FlightRequests[request_id].destination
            );
    }

    // client withdraws request for flight
    function cancelFlightRequest(uint request_id) public payable onlyClient {
        FlightRequests[request_id].cancelled = true;
        FlightRequests[request_id].clientAddress.transfer(FlightRequests[request_id].price);
        
        emit flightCancellationEvent(
            request_id,
            FlightRequests[request_id].cancelled
            );
    }

    // charter withdraws offered flight
    function cancelFlightOffer(uint offer_id) public onlyCharter {
        FlightOffers[offer_id].cancelled = true;
        
        emit flightCancellationEvent(
            offer_id,
            FlightOffers[offer_id].cancelled
            );
    }

    // client views flights offered
    function flightOffersNumber() public view returns(uint) {
        return offer_ids.current();
    }

    // charter views flight requests
    function flightRequestsNumber() public view returns(uint) {
        return request_ids.current();
    }
    
    mapping(uint => FlightAuction) public auctions;

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
    
    function endAuction(uint offer_id) public onlyCharter {
        FlightAuction auction = auctions[offer_id];
        auction.auctionEnd();
        safeTransferFrom(owner(), auction.highestBidder(), offer_id);
    }
    
    function createAuction(uint offer_id) internal {
        auctions[offer_id] = new FlightAuction(charterAddress, auctionTimeLength);
    }

}