# Episode #2

In part 1, the bike owner's address was embedded into the bike data message. While this method could be easily implemented through ownership settings in the bike-sharing mobile app, such as through Bluetooth, it has limitations. For example, it restricts Web3 composability, and the owner must have physical access to the bike to change ownership.

In part 2, we aim to manage bike owners in a more flexible manner by recording ownership information in a blockchain contract. Each manufactured bike will be registered on the blockchain in a dedicated device registry contract. The best way to achieve this is to implement an NFT token contract to "mint" any new manufactured bike. The simple existance of an NFT for a certain Bike Id means that bike is part of our ecosystem, while the ownership of the NFT is simply the owner of the bike. This provides lots of flexibility to our project as well as composability: in fact, bike owners can check their bikes in a Metamask wallet, they can easily transfer ownership, or even sell their bikes in any NFT marketplace.

Consequently, every time a bike sends data to our W3bstream prover, it will have to include its unique device ID to "identify" itself as one of our bikes. Ideally, the data message should also be signed but for the sake of simplicity we will skip this here. The applet will retrieve the current bike's owner information from the NFT contract on chain to determine where to send the payments for that bike. 

Let's outline the changes to the project below:

1. Each bike should be assigned a unique ID, which we will generate as a public/private key pair, using the public key as the bike's unique identifier (and, ideally, the private key should be used by the bike to sign messages).
2. We will create a "Bikes" NFT contract where the project owner will mint each manufactured bike, with the token id being the actual bike id (i.e. the public key mentioned above).
3. We will modify the W3bstream Applet to retrieve the owner for a particular bike from the bikes NFT contract to determine the correct recipient of the payment upon completing a ride.
4. Finally, we will modify the bike simulator to remove the owner address from the message and include the bike_id instead.