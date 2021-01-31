const LotteryNFT = artifacts.require("LotteryNFT");
const BigNumber = require("bignumber.js");

contract("LotteryNFT", function (accounts) {
  let ballotInstance;
  const expectedTotalTickets = 5;
  const priceTicket = 1;
  const dateLottery = "02012021";
  const expectedStatusLottery = [0,1,2];
  const ticketsLottery = [0,1,2,3,4];
  const expectedStatusTicket = [0,1,2]
  const expectedBalanceofBuyer1 = 2;
  const manager = accounts[0];
  const buyer1 = accounts[1];
  const buyer2 = accounts[2];
  const buyer3 = accounts[3];
  const buyer4 = accounts[4];
  const buyer5 = accounts[5];
  describe("Initial deployment", async () => {
    before(async () => {
      LotteryNFTIntance = await LotteryNFT.deployed();
    });

    it("Check initial status Lottery", async function () {
        let statusLottery = await LotteryNFTIntance.state.call();
        assert.equal(expectedStatusLottery[0],statusLottery,"State is not as expected");
    });

    it("Check initLottery()", async function () {
        //Check status = Init
        let statusLottery = await LotteryNFTIntance.state.call();
        assert.equal(expectedStatusLottery[0],statusLottery,"State is not as expected");
        //Init Lottery
        await LotteryNFTIntance.initLottery(dateLottery, priceTicket,{from: manager});
        let statusSaleLottery = await LotteryNFTIntance.state.call();
        assert.equal(expectedStatusLottery[1],statusSaleLottery,"State is not as expected");
    });

    it("Check createTicketLottery", async function () {
        //Check status = Sale
        let statusSaleLottery = await LotteryNFTIntance.state.call();
        assert.equal(expectedStatusLottery[1],statusSaleLottery,"State is not as expected");
        //Create Tickets
        for(let i = 0; i < expectedTotalTickets; i++){
            await LotteryNFTIntance.createTicketLottery({from: manager});
        }
        //Check price, date, status, manager, owner
        let dataTicket1 = await LotteryNFTIntance.ticketsLottery(ticketsLottery[1]);
        assert.equal(dataTicket1.price,priceTicket,"Price ticket is not as expected");
        assert.equal(dataTicket1.date,dateLottery,"Date ticket is not as expected");
        assert.equal(dataTicket1.status,expectedStatusTicket[0],"Status ticket is not as expected");
        assert.equal(dataTicket1.manager,manager,"Manager ticket is not as expected");
        assert.equal(dataTicket1.owner,manager,"Owner ticket is not as expected");

        //Check totalSupply
        let totalTickets = await LotteryNFTIntance.totalSupply.call();
        assert.equal(expectedTotalTickets,totalTickets,"Total tickets are not as expected");
    });

    it("Check approve()", async function () {
        //Approve ticket[0] to buyer1
        await LotteryNFTIntance.approve(buyer1,ticketsLottery[0]);
        await LotteryNFTIntance.approve(buyer2,ticketsLottery[1]);
        await LotteryNFTIntance.approve(buyer3,ticketsLottery[2]);
        await LotteryNFTIntance.approve(buyer4,ticketsLottery[3]);
        await LotteryNFTIntance.approve(buyer5,ticketsLottery[4]);
        //GetApproved ticket[1]
        let approvedTicket1 = await LotteryNFTIntance.getApproved(ticketsLottery[1]);
        assert.equal(approvedTicket1,buyer2,"Approved of ticket is not as expected");
        /*//Check  buyer1
        let balanceBuyer1 = await LotteryNFTIntance.balanceOf(buyer1);
        assert.equal(balanceBuyer1,expectedBalanceofBuyer1,"Balance of buyer is not as expected");*/
    });
    /*it("Check ", async function () {
        
    });*/

  });
});
