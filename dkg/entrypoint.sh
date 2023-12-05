#!/bin/sh

OPERATOR_CONFIG_DIR=${OPERATOR_DATA_DIR}/config
DKG_CONFIG_DIR=${DKG_DATA_DIR}/config
DKG_LOGS_DIR=${DKG_DATA_DIR}/logs

PRIVATE_KEY_FILE=${OPERATOR_CONFIG_DIR}/encrypted_private_key.json
PRIVATE_KEY_PASSWORD_FILE=${OPERATOR_CONFIG_DIR}/private_key_password
DKG_CONFIG_FILE=${DKG_CONFIG_DIR}/dkg-config.yml
DKG_LOG_FILE=${DKG_LOGS_DIR}/dkg.log

# Wait for 10s to give the operator service time to create the private key and password files.
echo "Waiting for the operator service to create the private key and password files..."
sleep 10

if [ ! -f "${PRIVATE_KEY_FILE}" ] || [ ! -f "${PRIVATE_KEY_PASSWORD_FILE}" ]; then
    echo "Private key or password file not found. They should have been created by the operator service."
    echo "Retrying in 1min..."
    sleep 60
    exit 1
fi

# Create the DKG config file.
yq e -i ".privKey = \"${PRIVATE_KEY_FILE}\"" "${DKG_CONFIG_FILE}"
yq e -i ".privKeyPassword = \"${PRIVATE_KEY_PASSWORD_FILE}\"" "${DKG_CONFIG_FILE}"
yq e -i ".port = strenv(DKG_PORT)" "${DKG_CONFIG_FILE}"
yq e -i ".logLevel = strenv(LOG_LEVEL)" "${DKG_CONFIG_FILE}"

exec /app start-operator --configPath ${DKG_CONFIG_FILE}
