#!/bin/bash

# Array of environment tokens, including an empty string for production
ENVIRONMENTS=("dev-" "staging-" "")

# Use BASE_URL from the environment variable
BASE_URL="${API_BASE_URL}"

# Loop through each environment token
for ENVIRONMENT in "${ENVIRONMENTS[@]}"; do
    # Check if ENVIRONMENT is empty and print a custom message for production
    if [ -z "$ENVIRONMENT" ]; then
        echo "Fetching data for environment: production"
    else
        echo "Fetching data for environment: ${ENVIRONMENT}"
    fi
    
    # Construct the full URL
    FULL_URL="https://${ENVIRONMENT}${BASE_URL}"

    # Execute the curl and jq commands, and capture the output
    OUTPUT=$(curl -s "$FULL_URL" | jq '.verification.apis[] | select(.altID == "addressValidation") | {oAuth, oAuthInfo, oAuthTypes}')

    # Display the fetched data
    echo "$OUTPUT"
    
    # Check if oAuth is not false
    echo "$OUTPUT" | jq -e '.oAuth == false' > /dev/null || { echo "Error: oAuth is not false in the output above for $ENVIRONMENT"; exit 1; }

    # Check if oAuthInfo is not null
    echo "$OUTPUT" | jq -e '.oAuthInfo == null' > /dev/null || { echo "Error: oAuthInfo is not null in the output above for $ENVIRONMENT"; exit 1; }

    # Check if oAuthTypes is not null
    echo "$OUTPUT" | jq -e '.oAuthTypes == null' > /dev/null || { echo "Error: oAuthTypes is not null in the output above for $ENVIRONMENT"; exit 1; }

    echo "------------------------------------------------"
done
