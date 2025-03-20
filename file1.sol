pragma solidity ^0.8.0;

contract TimedAuction {
    struct Auction {
        address seller;
        uint256 startTime;
        uint256 endTime;
        uint256 highestBid;
        address highestBidder;
        bool ended;
    }
    
    mapping(uint256 => Auction) public auctions;
    uint256 private auctionCounter;
    
    event AuctionCreated(uint256 auctionId, uint256 endTime);
    event NewBid(uint256 auctionId, address bidder, uint256 amount);
    event AuctionEnded(uint256 auctionId, address winner, uint256 amount);
    
    function createAuction(uint256 duration) external {
        require(duration > 0, "Invalid duration");
        auctionCounter++;
        uint256 auctionId = auctionCounter;
        auctions[auctionId] = Auction(msg.sender, block.timestamp, block.timestamp + duration, 0, address(0), false);
        emit AuctionCreated(auctionId, block.timestamp + duration);
    }
    
    function placeBid(uint256 auctionId) external payable {
        Auction storage auction = auctions[auctionId];
        require(block.timestamp < auction.endTime, "Auction ended");
        require(msg.value > auction.highestBid, "Bid too low");
        
        if (auction.highestBidder != address(0)) {
            payable(auction.highestBidder).transfer(auction.highestBid);
        }
        
        auction.highestBid = msg.value;
        auction.highestBidder = msg.sender;
        emit NewBid(auctionId, msg.sender, msg.value);
    }
    
    function closeAuction(uint256 auctionId) external {
        Auction storage auction = auctions[auctionId];
        require(block.timestamp >= auction.endTime, "Auction not ended yet");
        require(!auction.ended, "Auction already closed");
        
        auction.ended = true;
        if (auction.highestBidder != address(0)) {
            payable(auction.seller).transfer(auction.highestBid);
        }
        
        emit AuctionEnded(auctionId, auction.highestBidder, auction.highestBid);
    }
}
