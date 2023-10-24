# Episode #2

In the previous episode, the bike owner's address was embedded into the bike data message. While this method could be easily implemented through ownership settings in the bike-sharing mobile app, such as through Bluetooth, it has limitations. For example, it restricts Web3 composability, and the owner must have physical access to the bike to change ownership.

In this episode, we aim to manage bike owners in a more flexible manner by recording ownership information in a blockchain contract. Each manufactured bike will be registered on the blockchain in a dedicated device registry contract. Consequently, every time a bike sends data to our W3bstream prover, it will have to include its unique device ID. The applet will retrieve the current owner's information from the blockchain registry to determine where to send the payments for that bike. If an owner wishes to sell their bike, they can interact with the "ownership" smart contract through the bike app to transfer ownership.

Let's outline the changes to the project below:

1. Each bike should be assigned a unique ID, which we will generate as a public/private key pair, using the public key as the bike's unique identifier.
2. We will create a DeviceRegistry contract where the project owner will list the unique IDs of each manufactured bike.
3. A DeviceBinding contract will be established to map each bike's unique ID to the wallet address of its owner.
4. We will modify the W3bstream Applet to retrieve the owner for a particular bike to determine the recipient of the payment upon completing a ride.

