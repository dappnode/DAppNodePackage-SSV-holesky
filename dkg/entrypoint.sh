#!/bin/sh

OPERATOR_CONFIG_DIR=${OPERATOR_DATA_DIR}/config
DKG_CONFIG_DIR=${DKG_DATA_DIR}/config
DKG_LOGS_DIR=${DKG_DATA_DIR}/logs
DKG_OUTPUT_DIR=${DKG_DATA_DIR}/output
DKG_DB_PATH=${DKG_DATA_DIR}/db

PRIVATE_KEY_FILE=${OPERATOR_CONFIG_DIR}/encrypted_private_key.json
PRIVATE_KEY_PASSWORD_FILE=${OPERATOR_CONFIG_DIR}/private_key_password
DKG_CONFIG_FILE=${DKG_CONFIG_DIR}/dkg-config.yml
DKG_LOG_FILE=${DKG_LOGS_DIR}/dkg.log

mkdir -p ${DKG_CONFIG_DIR} ${DKG_LOGS_DIR} ${DKG_OUTPUT_DIR}

# Wait indefinitely for the private key file to be created using inotifywait.
echo "[INFO] Waiting for the operator service to create the private key file..."
while [ ! -f "${PRIVATE_KEY_FILE}" ]; do
    echo "[INFO] Waiting for ${PRIVATE_KEY_FILE} to be created..."
    inotifywait -e create -qq $(dirname "${PRIVATE_KEY_FILE}")
done

echo "[INFO] Private key file found."

# Immediately check for the password file; log an error and exit with status 0 if not found.
if [ ! -f "${PRIVATE_KEY_PASSWORD_FILE}" ]; then
    echo "[ERROR] ${PRIVATE_KEY_PASSWORD_FILE} not found. Cannot continue without the private key password file."
    exit 0
fi

# TODO: Fetch operator ID using the operator public key
# If operator ID is not defined in the environment, exit.
if [ -z "${OPERATOR_ID}" ]; then
    echo "[ERROR] OPERATOR_ID is not defined. You must set it in the package config to perform the DKG."
    exit 0
fi

exec /bin/ssv-dkg start-operator \
    --operatorID ${OPERATOR_ID} \
    --configPath ${DKG_CONFIG_FILE} \
    --logFilePath ${DKG_LOG_FILE} \
    --logLevel ${LOG_LEVEL} \
    --outputPath ${DKG_OUTPUT_DIR} \
    --port ${DKG_PORT} \
    --privKey ${PRIVATE_KEY_FILE} \
    --privKeyPassword ${PRIVATE_KEY_PASSWORD_FILE}
