#!/bin/bash

OPERATOR_DB_DIR=${OPERATOR_DATA_DIR}/db
OPERATOR_LOGS_DIR=${OPERATOR_DATA_DIR}/logs
OPERATOR_CONFIG_DIR=${OPERATOR_DATA_DIR}/config

PRIVATE_KEY_FILE=${OPERATOR_CONFIG_DIR}/encrypted_private_key.json
PRIVATE_KEY_PASSWORD_FILE=${OPERATOR_CONFIG_DIR}/private_key_password
OLD_PRIVATE_KEY_PASSWORD_FILE=${OPERATOR_CONFIG_DIR}/old_private_key_password
DEFAULT_PRIVATE_KEY_FILE=/encrypted_private_key.json
NODE_CONFIG_FILE=${OPERATOR_CONFIG_DIR}/node-config.yml
NODE_LOG_FILE=${OPERATOR_LOGS_DIR}/node.log

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

# Check if the private key pass file exists
if [ -f "${PRIVATE_KEY_PASSWORD_FILE}" ]; then
  STORED_PRIVATE_KEY_PASS=$(cat ${PRIVATE_KEY_PASSWORD_FILE})

  # Check if PRIVATE_KEY_PASS is set and if it is different from the stored pass
  if [ -n "${PRIVATE_KEY_PASS}" ] && [ "${PRIVATE_KEY_PASS}" != "${STORED_PRIVATE_KEY_PASS}" ]; then
    echo "The private key password has changed. Updating it..."
    mv ${PRIVATE_KEY_FILE} ${PRIVATE_KEY_FILE}.old
    echo "${PRIVATE_KEY_PASS}" >${PRIVATE_KEY_PASSWORD_FILE}
  fi
elif [ -n "${PRIVATE_KEY_PASS}" ]; then
  echo "Storing the private key password..."
  echo "${PRIVATE_KEY_PASS}" >${PRIVATE_KEY_PASSWORD_FILE}
else
  echo "Generating a random password for the operator keys..."
  openssl rand -base64 12 >${PRIVATE_KEY_PASSWORD_FILE}
fi

if [ ! -f "${PRIVATE_KEY_FILE}" ]; then

  # If the private keys in the default location, move it to the proper location.
  if [ ! -f "${DEFAULT_PRIVATE_KEY_FILE}" ]; then

    echo "Generating operator keys..."
    /go/bin/ssvnode generate-operator-keys --password-file ${PRIVATE_KEY_PASSWORD_FILE}
  fi

  echo "Moving private key to the proper location..."
  mv ${DEFAULT_PRIVATE_KEY_FILE} ${PRIVATE_KEY_FILE}

else
  echo "Operator keys already exist"
fi

# Read JSON from PRIVATE_KEY_FILE and extract the publicKey
PUBLIC_KEY=$(jq -r '.publicKey' ${PRIVATE_KEY_FILE})

# Post ENR to dappmanager
curl --connect-timeout 5 \
  --max-time 10 \
  --silent \
  --retry 5 \
  --retry-delay 0 \
  --retry-max-time 40 \
  -X POST "http://dappmanager.dappnode/data-send?key=NodePublicKey&data=${PUBLIC_KEY}" ||
  {
    echo -e "[ERROR] failed to post public key to dappmanager\n"
    exit 1
  }

echo -e "\nPUBLIC_KEY=${PUBLIC_KEY}\n"

# Create the node config file.
yq e -i ".global.LogLevel = strenv(LOG_LEVEL)" "${NODE_CONFIG_FILE}"
yq e -i ".global.LogFilePath = \"${NODE_LOG_FILE}\"" "${NODE_CONFIG_FILE}"
yq e -i ".db.Path = \"${OPERATOR_DB_DIR}\"" "${NODE_CONFIG_FILE}"
yq e -i ".ssv.Network = strenv(NETWORK)" "${NODE_CONFIG_FILE}"
yq e -i ".ssv.ValidatorOptions.BuilderProposals = (strenv(BUILDER_PROPOSALS) == \"true\")" "${NODE_CONFIG_FILE}"
yq e -i ".eth2.BeaconNodeAddr = \"${BEACON_NODE_API}\"" "${NODE_CONFIG_FILE}"
yq e -i ".eth1.ETH1Addr = \"${EXECUTION_LAYER_WS}\"" "${NODE_CONFIG_FILE}"
yq e -i ".p2p.TCPPort = strenv(P2P_TCP_PORT)" "${NODE_CONFIG_FILE}"
yq e -i ".p2p.UDPPort = strenv(P2P_UDP_PORT)" "${NODE_CONFIG_FILE}"
yq e -i ".KeyStore.PrivateKeyFile = \"${PRIVATE_KEY_FILE}\"" "${NODE_CONFIG_FILE}"
yq e -i ".KeyStore.PasswordFile = \"${PRIVATE_KEY_PASSWORD_FILE}\"" "${NODE_CONFIG_FILE}"

/go/bin/ssvnode start-node --config ${NODE_CONFIG_FILE} ${EXTRA_OPTS}
