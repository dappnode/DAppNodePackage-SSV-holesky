# SSV Holesky

This package allows Dappnode Users to help test the SSV Network. A pioneer in the field of DVT (Decentralized Validator Technology), SSV is a network of validators that use a decentralized network of operators to run their validators. This package allows you to run an SSV Operator Node on the network Holesky.

## _**IMPORTANT**_

- _This package requires a synced Ethereum Holesky Testnet Client Stack, as configured in the [Holesky Stakers UI](http://my.dappnode/stakers/holesky) in order to function properly._
- As soon as the Operator registration is done, make sure to **download the Backup** in the [Backup tab](http://my.dappnode/packages/my/ssv-holesky.dnp.dappnode.eth/backup) to not loose any critical files.

### Operator Registration

Registration is free and open to anyone who wishes to operate other validators, and is done by broadcasting a transaction to the SSV network smart contract with your Operator's display name and public key that was generated as part of your node setup.

Register your new operator (_Do not reuse operators from the V1 "Primus" testnet or V2 "Shifu"_) using this [Web App](https://app.ssv.network/join/operator/register) or [https://beta.app.ssv.network/join/operator/register](https://beta.app.ssv.network/join/operator/register) **before September 18, 2023**.

After registration, your operator becomes discoverable as one of the network's operators and SSV stakers can choose you as one of their validator's operators.

#### Registration Steps

1. Go to the [SSV network WebApp](https://app.ssv.network/join).
2. Change the network to _Holesky_ in the top right corner.
3. Click the _Connect Wallet_ button to connect your Web3 wallet. Ensure that the address corresponds with the one you want to manage your Operators with.
4. Select _Join as Operator_.
5. Ensure that the SSV package is running and continue selecting _Register Operator_.
6. Provide your Operator's public key in the input and click _Next_.
7. Set the Operator Fee and click _Next_.
8. A confirmation screen will appear with all the inputted data. Double check everything and click _Register Operator_.
9. The WebApp will generate a blockchain transaction, make sure to open your Web3 wallet, if it does not automatically and confirm the transaction.
10. Wait for the transaction to be confirmed by the network. When ready, the WebApp will update and display a successfully register dialog.

You can also follow these steps in a more complete guide in the [SSV documentation](https://docs.ssv.network/operator-user-guides/operator-management/registration).

Full official documentation can be found [here](https://docs.ssv.network/learn/introduction).
