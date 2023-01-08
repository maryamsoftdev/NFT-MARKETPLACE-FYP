// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;
//INTERNAL IMPORT FOR NFT OPENZEPPELIN
import "@openzeppelin/contracts/utils/counters.sol"; 
// USE FOR NFT'S COUNTS
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

import "hardhat/console.sol";

contract NFTMarketplace is ERC721URIStorage{
    using Counters for Counters.Counter;


    Counters.Counter private _tokenIds;
    Counters.Counter private _itemsSold;
    uint256 listingPrice = 0.0025 ether;
    //KEEP THE TRACK HOW MANY ITEMS ARE SOLD
    address payable owner;
    //who ever will deploy the NFT will become owner

    mapping(uint256 => MarketItem) private idMarketItem;
   //STRUCTURE
    struct MarketItem{
        uint256 tokenId;
        address payable seller;
        address payable owner;
        uint256 price;
        bool sold;
        //WILL KEEP TRACK WEATHER THE NFT IS SOLD OR UNSOLD
    }
//STRUCTURE OVER WHICH WE ARE MAPPING THROUGH
   event idMarketItemCreated(
    uint256 indexed tokenId,
    address seller,
    address owner,
    uint256 price,
    bool sold
   );
// WHENEVER ANY KIND OF EVENT(BUYING OR SELLING) WILL HAPPEN IT WIL TRIGGER THE EVENT
 modifier onlyOwner {
require(
    msg.sender == owner,
    "only owner of the marketplace can change the listing price"
    );
  _;
  //THIS MODIFIER FUNCTION WILL TRUE THEN OTHER FUCNTION WILL KEEP WORKING
 }
constructor() ERC721("NFT Metavarse Token" , "MYNFT"){
//NFT NAME AND SYMBOL IS DEFINE ACCOCCORDING TO RULES
owner == payable(msg.sender);
}
//PRICE FOR OWNER
//ONLY OWNER CAN CHANGE THE PRICE SO WE HAVE CREATED A MODIFIER FOR THAT ON LINE NO. named as only owner 
function updateListingPrice(uint256 _listingPrice)
 public
payable
onlyOwner
{
    listingPrice = _listingPrice;
}
function getListingPrice() public view returns(uint256){
   return listingPrice; 
}
//LISTINGPRICE IS THE STATE VARIABLE
//SO THAT EVERY ONE CAN CHECK HOW MUCH AMOUNT THEY HAVE TO PAY
//IT WILL BE PUBLIC SO EVERY BODY CAN VIEW

function createToken(string memory tokenURI, uint256 price ) public payable returns(uint256){

_tokenIds.increment();
uint256 newTokenId = _tokenIds.current();

_mint(msg.sender, newTokenId);
_setTokenURI(newTokenId, tokenURI);

//we are using this mint function from open zeppelin go to defination
//LET CREATE "CREATE NFT TOKEN FUNCTION"
createMarketItem(newTokenId, price);
return newTokenId;
}
//CREATING MARKET ITEM
function createMarketItem(uint256 tokenId, uint256 price) private{
//WE WILL SET REQUIRE FOR SOME CHECKS
require(price > 0, "Price must be at least 1 wei");
require(msg.value == listingPrice, "price must be equal to listing price");
idMarketItem[tokenId] = MarketItem(
 tokenId,
 payable(msg.sender),
 payable(address(this)),
 price,
 false
//NFT AND MONEY BELONG TO THE CONTRACT ITSELF

);
_transfer(msg.sender, address(this), tokenId);
emit idMarketItemCreated(
    tokenId,
    msg.sender,  
    address(this),
    price,
    false
        );
}

//PRIVATE BECUSE WE ARE CALLING IT INTERNALLY NOT EXTERNALLY

function reSellToken(uint256 tokenId, uint256 price) public payable{
 require(idMarketItem[tokenId].owner == msg.sender, "Only item owner can perform this operation");
//CHECKING IdMarketItem 
//IF BOTH ADDRESSES MATCHES THEN WE WILL CONTINUE WORKING FURTHURE AND MAKE THE RESALE HAPPEN
require(msg.value == listingPrice, "Price must be equal to listing price");

idMarketItem[tokenId].sold = false;
idMarketItem[tokenId].price = price;
idMarketItem[tokenId].seller = payable(msg.sender);
idMarketItem[tokenId].owner = payable(address(this));

_itemsSold.decrement();
// _itemsSold.decrement();
_transfer(msg.sender, address(this), tokenId);
}
//FUNCTION FOR RESALE TOKEN

function createMarketSale(uint256 tokenId) public payable{
    uint256 price = idMarketItem[tokenId].price;
    //PRICE IS COMING FROM STRUCTURE
    require(
        msg.value == price,
     "Please submit the asking price in oreder to complete the procedure"
     );

     idMarketItem[tokenId].owner = payable(msg.sender);
     idMarketItem[tokenId].sold = true;
     idMarketItem[tokenId].owner = payable(address(0));
//WHO EVER WILL PAY BECOME THE OWNER OF THE NFT
//JUST UPDATING THE DATA AND TRANSFERERING ON ADDRESS TO THE OTHER
      _itemsSold.increment();
      
      _transfer(address(this), msg.sender, tokenId);
//WHEN SOMEONE BUY THE NFT TOKEN THEY WILL BUY FROM CONTRACT
      payable(owner).transfer(listingPrice);
      payable(idMarketItem[tokenId].seller).transfer(msg.value);
//WHEN EVER ANY SALE WILL HAPPEN WE WILL GET OUR COMMISIION
}
//FUNTION CREATE MARKETSALE
//WE WILL GET UNSOLD ITEM BY OBVE FUNCTION
function fetchMarketItem() public view returns(MarketItem[] memory){
    uint256 itemCount = _tokenIds.current();
    uint256 unSoldItemCount = _tokenIds.current() - _itemsSold.current();
    uint256 currentIndex = 0;

    MarketItem[] memory items = new MarketItem[](unSoldItemCount);
        for(uint256 i =0; i < itemCount; i++){
            if(idMarketItem[i+1].owner == address(this)){
                uint256 currentId = i + 1;
                MarketItem storage currentItem = idMarketItem[currentId];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        
    }
        return items;
//NEW IS THE KEYWORD IN SOLIDITY
}
//GETTING UNSOLD NFT DATA

function fetchMyNFT() public view returns(MarketItem[] memory){
//RETURNING ARRAY BECAUSE ONE PERSON CAN HAVE MULTIPLE NFT'S
    uint256 totalCount = _tokenIds.current();
    uint256 itemCount = 0;
    uint256 currentIndex = 0;

    for(uint256 i=0; i<totalCount; i++){
        if(idMarketItem[i+1].owner == msg.sender){
            itemCount+= 1;
        }
    }
    MarketItem[] memory items = new MarketItem[](itemCount);
    for(uint256 i =0; i< totalCount; i++){
       if(idMarketItem[i+1].owner == msg.sender){
        uint256 currntId = i+1;
        MarketItem storage currentItem = idMarketItem[currntId];
         items[currentIndex] = currentItem;
         currentIndex +=1;
       }
    }
    return items;
}
//PURCHASE ITEM
function fetchItemsListed() public view returns(MarketItem[] memory)
{
 uint256 totalCount = _tokenIds.current();
 uint256 itemCount = 0;
 uint256 currentIndex =0;

 for(uint256 i = 0; i< totalCount; i++){
if(idMarketItem[i+1].seller == msg.sender){
    itemCount += 1;

}

 }
MarketItem[] memory items = new MarketItem[](itemCount);
for(uint256 i = 0; i< totalCount; i++){
    if(idMarketItem[i+1].seller == msg.sender){
        uint256 currentId = i+1;
        MarketItem storage currentItem = idMarketItem[currentId];
        items[currentIndex] = currentItem;
          currentIndex += 1;

    }
}
return items;
}

//SINGLE USER ITEMS
}
