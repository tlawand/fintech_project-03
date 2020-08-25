    // TO BE INCLUDED IN THE JETCHAIN-721.SOL
    
    address payable charterAddress;
    uint auctionTimeLength;

    mapping(uint => FlightAuction) public auctions;

    modifier flightRegistered(uint token_id) {
        require(_exists(token_id), "Flight not registered!");
        _;
    }

    function createAuction(uint token_id) public onlyOwner {
        auctions[token_id] = new FlightAuction(charterAddress, auctionTimeLength);
    }

    function registerFlight(string memory uri) public payable onlyOwner {
        token_ids.increment();
        uint token_id = token_ids.current();
        _mint(charterAddress, token_id);
        _setTokenURI(token_id, uri);
        createAuction(token_id);
    }


    function endAuction(uint token_id) public onlyOwner flightRegistered(token_id) {
        FlightAuction auction = auctions[token_id];
        auction.auctionEnd();
        safeTransferFrom(owner(), auction.highestBidder(), token_id);
    }

    function auctionEnded(uint token_id) public view returns(bool) {
        FlightAuction auction = auctions[token_id];
        return auction.ended();
    }

    function highestBid(uint token_id) public view flightRegistered(token_id) returns(uint) {
        FlightAuction auction = auctions[token_id];
        return auction.highestBid();
    }

    function pendingReturn(uint token_id, address sender) public view flightRegistered(token_id) returns(uint) {
        FlightAuction auction = auctions[token_id];
        return auction.pendingReturn(sender);
    }

    function bid(uint token_id) public payable flightRegistered(token_id) {
        FlightAuction auction = auctions[token_id];
        auction.bid.value(msg.value)(msg.sender);
    }