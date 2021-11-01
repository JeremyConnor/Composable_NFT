# Standard and VIP Composable Tickets for Conference
Users who want to be a part of conference have an option to buy Standard or VIP Tickets.

## Properties of Tickets
* Tickets are of type Standard and VIP,
* Standard Tickets are cheaper than VIP Tickets,
* Price of Tickets start at a certain price, begin to increase after certain entries and maxes out at particular number of entries.
* Standard Tickets are Composable NFTs with specific amount of Snack Tokens
* VIP Tickets have more number of Snack Tokens as compared to Standard Token.
* VIP Tokens also have NFT inside the Composable Ticket.

## Using the ConfereneTicket
User can call the following functions
1) `checkStandardTicketPrice` to check the current price of Standard Ticket.
2) `checkVIPTicketPrice` to check current price of VIP Ticket.
3) `buyStandardTicket` to buy composable conference tickets of Standard type.
4) `buyVIPTicket` to buy composable conference tickets of VIP type 

## Approach

The first approach was to set the binding function for the price. I considered using a sigmoid price function. But, due to expensive calculations, I simplified the sigmoid function into a 3 part linear function which requires lesser computation and does the job.
Since the constituents of Standard and VIP tokens is not mentioned, I made provided them fixed value of Snack tokens. But, to distinguish the VIP tokens from the Snack tokens, I have wrapped the VIP token with another composable NFT containing some extra Snack Token. 