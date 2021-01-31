// SPDX-License-Identifier: MIT

pragma solidity >=0.5.0 <0.8.0;

//import "github.com/OpenZeppelin/openzeppelin-solidity/contracts/token/ERC721/ERC721.sol";

import "./contracts/token/ERC721/ERC721.sol";

contract LotteryNFT is ERC721("LotteryNGF", "LNFT"){
    
    enum ticketStatus {FOR_SALE, SOLD, DESTROY}
    uint private randNonce = 0;
    string public dateLottery;
	uint256 public priceLottery;
	address public manager = msg.sender;
	
    struct TicketLottery{
        uint256 id;
        uint256 price;
        string date;
        ticketStatus status;
        address payable manager;
        address payable owner;
    }

    enum Phase {Init, Sale, Draw}
    Phase public state= Phase.Init;
    
    TicketLottery [] public ticketsLottery;
    
    mapping(uint256 => TicketLottery) public tokens;
    
    /*constructor(){
		manager = msg.sender;
		state = Phase.Init;
	}*/

	
    modifier validStatus(ticketStatus _status, uint256 _tokenId) {
        TicketLottery memory ticketLottery = tokens[_tokenId];
        require(ticketLottery.status == _status);
        _;
    }
    
    modifier onlyOwner(uint256 _tokenId){
        require(msg.sender == (super.ownerOf(_tokenId)), "No owner of the Token");
        _;
    }
    
    modifier onlyManager() {
        require(msg.sender  == manager,"Your not the manager");
        _;
    }
    
    modifier validPhase(Phase reqPhase) {
        require(state == reqPhase);
        _;
    }
	
	function initLottery(string memory _dateLottery, uint256 _priceLottery)public validPhase(Phase.Init) onlyManager{
	    dateLottery = _dateLottery;
		priceLottery = _priceLottery;
		state = Phase.Sale;
	}
	
	function changeState(Phase x) public onlyManager {
        require(x > state);
        state = x;
    }
   
    function createTicketLottery() public validPhase(Phase.Sale) onlyManager {
        TicketLottery memory _ticketLottery = TicketLottery ({
            id : 0,
            price: priceLottery,
            date: dateLottery,
            status: ticketStatus.FOR_SALE, 
            manager:msg.sender,
            owner:msg.sender
        });
        
        ticketsLottery.push(_ticketLottery);
        uint256 tokenId = ticketsLottery.length - 1;
        _safeMint(msg.sender, tokenId);
        uint _index = tokenOfOwnerByIndex(msg.sender, tokenId);
        ticketsLottery[_index].id = _index;
        tokens[tokenId]=_ticketLottery;
     }
     
     function approveTransferToken(address _attendee, uint256 _tokenId) public onlyOwner(_tokenId) validStatus(ticketStatus.FOR_SALE, _tokenId){
         TicketLottery memory consultingService= tokens[_tokenId];
         super.approve(_attendee, _tokenId);
         emit Approval(consultingService.owner, _attendee, _tokenId);
     }
     
     function approvalForAll(address _attendee) public{
         require(_attendee != address(0x0));
         super.setApprovalForAll(_attendee, true);
         emit ApprovalForAll(msg.sender, _attendee, true);
     }
     
     function validateIsApprovedForAll(address _attendee) public returns(bool){
         
     }
     
     function existsToken(uint256 _tokenId) internal view returns(bool) {
        return (!(tokens[_tokenId].price == 0));
     }
    
     function buyTicketLottery(uint256 _tokenId) payable public validStatus(ticketStatus.FOR_SALE, _tokenId) validPhase(Phase.Sale) 
     {
            require(existsToken(_tokenId),"TicketLottery: nonexistant token");
            TicketLottery memory ticketLottery= tokens[_tokenId];
            uint256 index = ticketLottery.id;
            require(super.getApproved(_tokenId) == msg.sender, "Your are not the owner");
            require(msg.value >= ticketLottery.price, "Balance less than the price");
            require(msg.sender != address(0), "Addres invalid");
            if(msg.value > ticketLottery.price){
                msg.sender.transfer(msg.value - ticketLottery.price);
            }
            ticketLottery.owner.transfer(ticketLottery.price);
            super.transferFrom(ticketLottery.owner, msg.sender, _tokenId);
            emit Transfer(ticketLottery.owner, msg.sender, _tokenId);
            ticketsLottery[index].owner =msg.sender;
            ticketsLottery[index].status = ticketStatus.SOLD;
     }
     
     function closeSale() public validPhase(Phase.Sale) onlyManager{
         state = Phase.Draw;
     }
     
     function pickWinner() public onlyManager validPhase(Phase.Draw) returns(address, uint256) {
         uint numTickets = ticketsLottery.length;
         uint256 tokenWinner = uint(keccak256(abi.encodePacked(block.timestamp, msg.sender, randNonce))) % numTickets; 
         state = Phase.Init;
         return (ownerOf(tokenWinner), tokenWinner);
     }
     
     
}