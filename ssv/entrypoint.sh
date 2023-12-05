#!/bin/bash

PRIVATE_KEY_FILE=${SSV_ROOT_DIR}/encrypted_private_key.json
PRIVATE_KEY_PASSWORD_FILE=${SSV_ROOT_DIR}/private_key_password
DEFAULT_PRIVATE_KEY_FILE=/encrypted_private_key.json

NODE_CONFIG_PATH=/ssv-operator/node-config.yml
DKG_CONFIG_PATH=/ssv-operator/dkg-config.yml

DB_PATH=${DATA_PATH}/db
DKG_LOG_FILE=${DATA_PATH}/dkg.log
NODE_LOG_FILE=${DATA_PATH}/node.log

# Assign proper value to _DAPPNODE_GLOBAL_EXECUTION_CLIENT_HOLESKY.
case "$_DAPPNODE_GLOBAL_EXECUTION_CLIENT_HOLESKY" in
"holesky-geth.dnp.dappnode.eth") EXECUTION_LAYER_WS="ws://holesky-geth.dappnode:8546" ;;
"holesky-nethermind.dnp.dappnode.eth") EXECUTION_LAYER_WS="ws://holesky-nethermind.dappnode:8546" ;;
"holesky-besu.dnp.dappnode.eth") EXECUTION_LAYER_WS="ws://holesky-besu.dappnode:8546" ;;
"holesky-erigon.dnp.dappnode.eth") EXECUTION_LAYER_WS="ws://holesky-erigon.dappnode:8545" ;;
*)
  echo "Unknown value for _DAPPNODE_GLOBAL_EXECUTION_CLIENT_HOLESKY. Please confirm that the value is correct."
  exit 1
  ;;
esac

# Assign proper value to _DAPPNODE_GLOBAL_CONSENSUS_CLIENT_HOLESKY.
case "$_DAPPNODE_GLOBAL_CONSENSUS_CLIENT_HOLESKY" in
"prysm-holesky.dnp.dappnode.eth") BEACON_NODE_API="http://beacon-chain.prysm-holesky.dappnode:3500" ;;
"teku-holesky.dnp.dappnode.eth") BEACON_NODE_API="http://beacon-chain.teku-holesky.dappnode:3500" ;;
"lighthouse-holesky.dnp.dappnode.eth") BEACON_NODE_API="http://beacon-chain.lighthouse-holesky.dappnode:3500" ;;
"nimbus-holesky.dnp.dappnode.eth") BEACON_NODE_API="http://beacon-validator.nimbus-holesky.dappnode:4500" ;;
"lodestar-holesky.dnp.dappnode.eth") BEACON_NODE_API="http://beacon-chain.lodestar-holesky.dappnode:3500" ;;
*)
  echo "_DAPPNODE_GLOBAL_CONSENSUS_CLIENT_HOLESKY env is not set properly."
  exit 1
  ;;
esac

if [ ! -f "${PRIVATE_KEY_FILE}" ]; then

  # If the private keys in the default location, move it to the proper location.
  if [ ! -f "${DEFAULT_PRIVATE_KEY_FILE}" ]; then

    echo "Generating a random password for the operator keys..."
    openssl rand -base64 12 >${PRIVATE_KEY_PASSWORD_FILE}

    echo "Generating operator keys..."
    /go/bin/ssvnode generate-operator-keys --password-file ${PRIVATE_KEY_PASSWORD_FILE}
  fi

  echo "Moving private key to the proper location..."
  mv ${DEFAULT_PRIVATE_KEY_FILE} ${PRIVATE_KEY_FILE}

else
  echo "Operator keys already exist"
fi

# Create the DKG config file.
yq e -i ".privKey = \"${PRIVATE_KEY_FILE}\"" "${DKG_CONFIG_PATH}"
yq e -i ".privKeyPassword = \"${PRIVATE_KEY_PASSWORD_FILE}\"" "${DKG_CONFIG_PATH}"
yq e -i ".port = strenv(DKG_PORT)" "${DKG_CONFIG_PATH}"
yq e -i ".logLevel = strenv(LOG_LEVEL)" "${DKG_CONFIG_PATH}"

# Create the node config file.
yq e -i ".global.LogLevel = strenv(LOG_LEVEL)" "${NODE_CONFIG_PATH}"
yq e -i ".global.LogFilePath = \"${NODE_LOG_FILE}\"" "${NODE_CONFIG_PATH}"
yq e -i ".db.Path = \"${DB_PATH}\"" "${NODE_CONFIG_PATH}"
yq e -i ".ssv.Network = strenv(NETWORK)" "${NODE_CONFIG_PATH}"
yq e -i ".ssv.ValidatorOptions.BuilderProposals = (strenv(BUILDER_PROPOSALS) == \"true\")" "${NODE_CONFIG_PATH}"
yq e -i ".eth2.BeaconNodeAddr = \"${BEACON_NODE_API}\"" "${NODE_CONFIG_PATH}"
yq e -i ".eth1.ETH1Addr = \"${EXECUTION_LAYER_WS}\"" "${NODE_CONFIG_PATH}"
yq e -i ".p2p.TCPPort = strenv(P2P_TCP_PORT)" "${NODE_CONFIG_PATH}"
yq e -i ".p2p.UDPPort = strenv(P2P_UDP_PORT)" "${NODE_CONFIG_PATH}"
yq e -i ".KeyStore.PrivateKeyFile = \"${PRIVATE_KEY_FILE}\"" "${NODE_CONFIG_PATH}"
yq e -i ".KeyStore.PasswordFile = \"${PRIVATE_KEY_PASSWORD_FILE}\"" "${NODE_CONFIG_PATH}"

sleep infinity

/go/bin/ssvnode start-node --config ${NODE_CONFIG_PATH}
