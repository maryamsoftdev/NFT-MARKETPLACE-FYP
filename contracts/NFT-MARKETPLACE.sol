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


    
)
}

//PRIVATE BECUSE WE ARE CALLING IT INTERNALLY NOT EXTERNALLY


}
