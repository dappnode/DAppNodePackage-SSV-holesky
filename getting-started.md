# **SSV Holesky**

SSV is a network of validators that use a decentralized network of operators to run their validators. This package allows you to run an SSV Operator Node on the network Holesky.

## Requirements

1. This package **requires a synced Holesky Node**, configured in the [Holesky Stakers UI](http://my.dappnode/stakers/holesky) in order to function properly.

2. As soon as the Operator registration is done, make sure to **download the Backup** in the [Backup tab](http://my.dappnode/packages/my/ssv-holesky.dnp.dappnode.eth/backup) to avoid losing any critical files.

## Registration Steps

1. Install the package setting the setup mode to "New Operator".

2. Get the operator punblic key that will be shown in the [SSV Info Tab](http://my.dappnode/packages/my/ssv-holesky.dnp.dappnode.eth/info).

3. Register as an operator following the [SSV documentation](https://docs.ssv.network/operator-user-guides/operator-management/registration) with the public key obtained in step 2.

## Troubleshoting

- If the `OPERATOR_ID` is not automatically fetched in dkg service from SSV API, you can manually set it in the [SSV Config Tab](http://my.dappnode/packages/my/ssv-holesky.dnp.dappnode.eth/config).

Full official documentation can be found [here](https://docs.ssv.network/learn/introduction).
