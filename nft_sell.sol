pragma solidity >=0.4.25 <0.9.0;

contract NFTSell {
    enum States {
        Deployed,
        WaitingSeller,
        WaitingBuyer,
        Sell,
        Retract,
        Locked
    }

    address payable private _buyerAddress;
    address payable private _sellerAddress;
    
    address private _assetAddress;
    uint256 private _tokenID;
    
    uint public _price;
    string public _asset;
    uint public _funds;

    States public _state;

    constructor(address payable seller_address, address payable buyer_address, address asset_address, uint price) {
        _state = States.Deployed;
        _sellerAddress = seller_address;
        _buyerAddress = buyer_address;
        _assetAddress = asset_address;
        price = _price;

        _state = States.WaitingSeller;
    }

    // TODO: The NFT part
    function add_asset() payable public {
        require(_state == States.WaitingSeller, "Not WaitingSeller state"); 

        require(msg.sender == _sellerAddress, "Not the seller's address");
        //require(msg.value == _assetAddress, "Not the right asset");
        //require(msg.value == _tokenID, "Not the right tokenID");

        _state = States.WaitingBuyer;
    }

    function add_funds() payable public {
        require(_state == States.WaitingBuyer, "Not the WaitingBuyer state");

        require(msg.sender == _buyerAddress, "Not the buyer's address");
        require(msg.value == _price, "Not the right price");
        _state = States.Sell;
        swap_ownership();
    }

    // TODO: retract needs to be payable for the gas fees of the retraction
    function retract_sell() public {
        require(_state == States.WaitingBuyer, "Cannot retract sell");
        _state = States.Retract;

        bool successSeller;
        //ERC721(_assetAddress).transferFrom(address, _buyerAddress, _tokenID);
        if (successSeller) {
            _state = States.Locked;
            lock();
        }
    }

    // TODO: The NFT part
    function swap_ownership() private{
        require(_state == States.Sell, "Could not swap ownership yet");

        (bool successSeller, ) = _sellerAddress.call{value: _price}("");
        require(successSeller, "Failed to send money to seller");

        bool successBuyer;
        //ERC721(_assetAddress).transferFrom(address, _buyerAddress, _tokenID);
        if (successSeller && successBuyer) {
            _state = States.Locked;
            lock();
        }
    }

    function lock() private{
    }
}