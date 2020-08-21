pragma solidity ^0.5.3;


// check and edit below interface
interface jetCoin {
    enum TokenType { Fungible, NonFungible }
    struct Coin { string obverse; string reverse; }
    function transfer(address recipient, uint amount) external;
}

contract jetChain {

    // client creates flight request
    function createFlightRequest() public payable {
        // TODO
    }

    // charter creates a flight offer (for empty leg)
    function createFlightOffer(
        string memory _origin,
        string memory _destination,
        uint memory passengers,
        uint memory price
        ) public {

    }

    // client confirms flight offered by charter
    function confirmFlightOffer() public payable {

    }

    // charter confirms client flight request
    function confirmFlightRequest() public {

    }

    // client withdraws request for flight
    function withdrawFlightRequest() public {

    }

    // client withdraws bid on flight offer
    function withdrawFlightBid() public {

    }

    // charter withdraws offered flight
    function withdrawFlightOffer() public {

    }

    // client bids on flight offered by charter
    function bidOnFlight() public payable {

    }

    // client views flights offered
    function viewOfferedFlights() public view {

    }

    // charter views flight requests
    function viewFlightRequests() public view {

    }

    // client confirms that flight has been completed
    function completeFlight() public {
        
    }

}