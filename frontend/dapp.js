const contractAddress = "0xe508d5e4ca79FE511a4Fe159082a12baBd298e4c"

const dApp = {
    ethEnabled: function() {
        // If the browser has an Ethereum provider (MetaMask) installed
        if (window.ethereum) {
          window.web3 = new Web3(window.ethereum);
          window.ethereum.enable();
          return true;
        }
        return false;
    },

    setAdmin: async function() {
        // if account selected in MetaMask is the same as owner then admin will show
        if (this.isAdmin) {
          $(".dapp-admin").show();
        } else {
          $(".dapp-admin").hide();
        }
    },
    updateUI: async function() {
        console.log("updating UI");
        // refresh variables
        await this.collectVars();
    
        $("#dapp-tokens").html("");
        this.tokens.forEach((token) => {
          try {
            let endAuction = `<a token-id="${token.tokenId}" class="dapp-admin" style="display:none;" href="#" onclick="dApp.endAuction(event)">End Auction</a>`;
            let bid = `<a token-id="${token.tokenId}" href="#" onclick="dApp.bid(event);">Bid</a>`;
            let owner = `Owner: ${token.owner}`;
            let withdraw = `<a token-id="${token.tokenId}" href="#" onclick="dApp.withdraw(event)">Withdraw</a>`
            let pendingWithdraw = `Balance: ${token.pendingReturn} wei`;
              $("#dapp-tokens").append(
                `<div class="col m6">
                  <div class="card">
                    <div class="card-image">
                      <img id="dapp-image" src="https://gateway.pinata.cloud/ipfs/${token.image.replace("ipfs://", "")}">
                      <span id="dapp-name" class="card-title">${token.name}</span>
                    </div>
                    <div class="card-action">
                      <input type="number" min="${token.highestBid + 1}" name="dapp-wei" value="${token.highestBid + 1}" ${token.auctionEnded ? 'disabled' : ''}>
                      ${token.auctionEnded ? owner : bid}
                      ${token.pendingReturn > 0 ? withdraw : ''}
                      ${token.pendingReturn > 0 ? pendingWithdraw : ''}
                      ${this.isAdmin && !token.auctionEnded ? endAuction : ''}
                    </div>
                    </div>
                </div>`
                );
            } catch (e) {
            alert(JSON.stringify(e));
            }
        });
    
        // hide or show admin functions based on contract ownership
        this.setAdmin();
    },
    bid: async function(event) {
        const offerID = $(event.target).attr("offer_id");
        const wei = Number($(event.target).prev().val());
        await this.jetChainContract.methods.bid(offerID).send({from: this.accounts[0], value: wei}).on("receipt", async (receipt) => {
          M.toast({ html: "Transaction Mined! Refreshing UI..." });
          await this.updateUI();
        });
      },
    endAuction: async function(event) {
        const offerID = $(event.target).attr("offer_id");
        await this.jetChainContract.methods.endAuction(offerID).send({from: this.accounts[0]}).on("receipt", async (receipt) => {
            M.toast({ html: "Transaction Mined! Refreshing UI..." });
            await this.updateUI();
        });
        },
    withdraw: async function(event) {
        const offerID = $(event.target).attr("offer_id") - 1;
        await this.tokens[offerID].auction.methods.withdraw().send({from: this.accounts[0]}).on("receipt", async (receipt) => {
          M.toast({ html: "Transaction Mined! Refreshing UI..." });
          await this.updateUI();
        });
        },

    flightOffersNumber: async function() {
        // const offerID = $(event.target).attr("offer_id") - 1;
        await this.jetChainContract.methods.flightOffersNumber().call();
    },

    isOwner: async function(event) {
        await this.jetChainContract.methods.isOwner().call();
    },

    main: async function() {
        // Initialize web3
        if (!this.ethEnabled()) {
          alert("Please install MetaMask to use this dApp!");
        }
    
        this.accounts = await window.web3.eth.getAccounts();
        this.contractAddress = contractAddress;
    
        this.jetChainJson = await (await fetch("./jetChain721.json")).json();
        this.auctionJson = await (await fetch("./jetChainAuction.json")).json();

        this.jetChainContract = new window.web3.eth.Contract(
          this.jetChainJson,
          this.contractAddress,
          { defaultAccount: this.accounts[0] }
        );
        console.log("Contract object", this.jetChainContract);
    
        this.isAdmin = this.accounts[0] == await this.jetChainContract.methods.owner().call();
    
        await this.updateUI();
      }
    };
    
dApp.main();