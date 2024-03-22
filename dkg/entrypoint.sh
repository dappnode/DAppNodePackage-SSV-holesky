#!/bin/sh

OPERATOR_CONFIG_DIR=${OPERATOR_DATA_DIR}/config
DKG_CONFIG_DIR=${DKG_DATA_DIR}/config
DKG_LOGS_DIR=${DKG_DATA_DIR}/logs
DKG_OUTPUT_DIR=${DKG_DATA_DIR}/output
DKG_DB_PATH=${DKG_DATA_DIR}/db

PRIVATE_KEY_FILE=${OPERATOR_CONFIG_DIR}/encrypted_private_key.json
PRIVATE_KEY_PASSWORD_FILE=${OPERATOR_CONFIG_DIR}/private_key_password
OLD_DKG_CONFIG_FILE=${DKG_CONFIG_DIR}/dkg-config.yml
DKG_CONFIG_FILE=${DKG_CONFIG_DIR}/config.yml
DKG_LOG_FILE=${DKG_LOGS_DIR}/dkg.log

mkdir -p ${DKG_CONFIG_DIR} ${DKG_LOGS_DIR} ${DKG_OUTPUT_DIR}

# Wait for 10s to give the operator service time to create the private key and password files.
echo "Waiting for the operator service to create the private key and password files..."
sleep 10

if [ -f "${OLD_DKG_CONFIG_FILE}" ]; then
    if [ ! -f "${DKG_CONFIG_FILE}" ]; then
        echo "Moving old DKG config file to the new location..."
        mv "${OLD_DKG_CONFIG_FILE}" "${DKG_CONFIG_FILE}"
    else
        echo "Removing old DKG config file..."
        rm "${OLD_DKG_CONFIG_FILE}"
    fi
fi

if [ ! -f "${PRIVATE_KEY_FILE}" ] || [ ! -f "${PRIVATE_KEY_PASSWORD_FILE}" ]; then
    echo "Private key or password file not found. They should have been created by the operator service."
    echo "Retrying in 1min..."
    sleep 60
    exit 1
fi

# If operator ID is not defined in the environment, exit.
if [ -z "${OPERATOR_ID}" ]; then
    echo "OPERATOR_ID is not defined. You must set it in the package config to perform the DKG."
    exit 1
fi

exec /bin/ssv-dkg start-operator \
    --operatorID ${OPERATOR_ID} \
    --configPath ${DKG_CONFIG_FILE} \
    --logFilePath ${DKG_LOG_FILE} \
    --logLevel ${LOG_LEVEL} \
    --operatorID ${OPERATOR_ID} \
    --outputPath ${DKG_OUTPUT_DIR} \
    --port ${DKG_PORT} \
    --privKey ${PRIVATE_KEY_FILE} \
    --privKeyPassword ${PRIVATE_KEY_PASSWORD_FILE}
