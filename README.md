# Composable NFTs
This project is an attempt to create composable NFTs. Composable NFTs are the ERC-721 tokens which can hold ERC-20 and even ERC-721 tokens. In this project, the NFTs are desgined to hold ERC-20 tokens.

## Using the MyComposableNFT
1) User can call `mint` function to mint a new composable NFT.
2) User can call `addFunds` function to add balance to the NFT.
3) User can call `transferNFT` function to transfer NFT to other eth addresses.
4) User can call `burn` function to burn the NFT and redeem all the ERC-20 tokens to his own eth address.

## Approach
### First thought
If I were to design this NFT without considering the metadata provided in OpenZepplin's ERC-721 contract, then a better approach would have been to store Owner's address and an `amount` parameter which would tell us the number of ERC-20 tokens stored/wrapped in the NFT. 
To scale the NFT a bit further, the `amount` parameter can be made to represent an array of uint, using which it will be possible to store values of multiple ERC-20 tokens. 
Another paramter `collectibles` can be introduced, which would contain the list of NFT's contained within these composable NFTs.

### Sticking to the OpenZepplin format
Since, we have to wrap ERC-20s with the NFT, the possible paramter which can help us here is the NFT's tokenID. TokenIDs are unique to every NFT and thus can be used to distinguish it from each other.

We are already following ERC-721 and ERC-20 standards, hence we need to tweak only some of the important functions, namely mint, transfer and burn.

Before diving into the code, let's have a look at the data structures which are necessary to make this possible.
1) A mapping to create a relation between tokenId and owner's address. (See in MyConposableNFT.sol)
2) A mapping to create a relation between tokenId and amount of ERC-20 tokens (See in MyERC20.sol)

The next step is to understand the process of data flow, or how the smart contract works
1) As soon as the user call the mint function, they will have to enter recepient's address and a unique token id. If the token id already exists, then the NFT will not be minted. (This is taken care by the ERC-721 standard).

2) Initially, my approach was to map the owner and NFT balance with the NFT's address. But, when we are calling the mint function, we are unaware of the NFT's address, therefore the idea was to create an additional function `addFunds` which will help us with this. Later on, I used the NFT's tokenId instead of the address for the purpose (Since, token id is unique as well), and didn't merge the functionalities of `mint` and `addFunds`. Another reason for this being, `mint` function calls `_mint` which is an internal function and hence introducing funds in this same function might increase the chances of vulnerabilities.
`addFunds` function calls the mintForNFT function (declared in MyERC20.sol). Using this function, the mapping is updated with token id and it's new balance and the ERC-20 tokens are minted to the MyERC20 contract address. (Reason discussed later)

3) Next comes the `transfer` function, which was farely straight forward. Since the balance of the NFT is bound to the token id, it's totally free of the owner. Hence, updating the mapping (token id => owner) alone does the work.

4) Last, but not the least, is the `burn` function. Here, the burn function burns only the NFT and not the ERC-20 token wrapped within it. This sort of acts as "Unlocking of tokens". The initial idea was to have a third parameter (boolean) which if true, would mean that the user wants to burn the wrapped tokens along with the NFT and if false, it will only burn the NFT and not the tokens. But, if give it a look, it's quite unconventional that a user would want to burn the ERC-20 tokens as well, hence I skipped over this idea. Rather, if a user wants to burn the ERC20-tokens, then they can separately call the burn function from the MyERC20 smart contract.
`burn` function will delete the mapping of token to it's owner and will transfer it's constituent ERC-20 tokens to the owner's eth address.

Coming to the point "Why are the ERC-20 tokens being minted to MyERC20 contract address?".
Well, it sort of acts as a vault. The balance of NFT will be safe when kept in a smart contract (provided that the smart contract is also safe). The owner of NFT can add as much funds as many times to the NFT as he wants, but will have to burn the NFT to get back the tokens. So, the ERC-20 tokens are locked until the NFT is burnt.
This also makes it easier and efficient to transfer the NFT. If, the MyERC20 tokens were stored in owner's eth address, then other than transferring the NFT, we will have to transfer the MyERC20 token as well. This would mean that the composable NFT is not acting like a vault. It's just binded by some tokens, which would differ from the project, and would make lesser sense.

What could be the other ways to store the ERC-20 token?
1) Storing it at owner's eth address.
=> This has quite some issues, let's have a look at them :
* The NFT's balance won't be fixed anymore. If the user spends MyERC20 tokens, then the NFT's balance will change as well. One method to somewhat solve this issue is, "Before transferring NFT, the user's eth address is checked. If it contains the same or more MyERC20 as the initial balance of NFT, then fine, otherwise, the user will be asked to buy some MyERC20 tokens to compensate the differnece."
2) Storing in an escrow sort of smart contract :
* This is quite possible, where we will have to descirbe the trigger events for the add and withdraw method of escrow. The escrow might need to be modified a bit.

NOTE : There can be more advancements made to the project idea and the code as well. But, in less than a span of 2 days, I devoted alot of time exploring the various scenarios, shortcomings and what the future of the project could look like. The code and the project have been built without using any external resources. I knew about the project being related to EIP-998, but I didn't read it, as I wanted to develop the crude idea that I got while reading the project title and it's requirements.