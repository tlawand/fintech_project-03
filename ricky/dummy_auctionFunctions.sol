    // TO BE INCLUDED IN THE JETCHAIN-721.SOL
    
    address payable charterAddress;
    uint auctionTimeLength;

    mapping(uint => FlightAuction) public auctions;

    modifier flightRegistered(uint offer_id) {
        require(_exists(offer_id), "Flight not registered!");
        _;
    }

    function createAuction(uint offer_id) public onlyOwner {
        auctions[offer_id] = new FlightAuction(charterAddress, auctionTimeLength);
    }

    function registerFlight(string memory uri) public payable onlyOwner {
        offer_ids.increment();
        uint offer_id = offer_ids.current();
        _mint(charterAddress, offer_id);
        _setTokenURI(offer_id, uri);
        createAuction(offer_id);
    }


    function endAuction(uint offer_id) public onlyOwner flightRegistered(token_id) {
        FlightAuction auction = auctions[offer_id];
        auction.auctionEnd();
        safeTransferFrom(owner(), auction.highestBidder(), offer_id);
    }

    function auctionEnded(uint offer_id) public view returns(bool) {
        FlightAuction auction = auctions[offer_id];
        return auction.ended();
    }

    function highestBid(uint offer_id) public view flightRegistered(offer_id) returns(uint) {
        FlightAuction auction = auctions[offer_id];
        return auction.highestBid();
    }

    function pendingReturn(uint offer_id, address sender) public view flightRegistered(offer_id) returns(uint) {
        FlightAuction auction = auctions[offer_id];
        return auction.pendingReturn(sender);
    }

    function bid(uint offer_id) public payable flightRegistered(offer_id) {
        FlightAuction auction = auctions[offer_id];
        auction.bid.value(msg.value)(msg.sender);
    }
