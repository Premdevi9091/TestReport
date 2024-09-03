#!/bin/bash

# Set your Jira base URL and Bearer token
BASE_URL="your_base_url_here"  # Replace with your Jira base URL
BEARER_TOKEN="your_bearer_token_here"  # Replace with your Jira Bearer token

# Input and Output CSV files
INPUT_CSV="input.csv"  # Path to your input CSV file
OUTPUT_CSV="output.csv"  # Path to your output CSV file

# Create the output CSV file with headers
echo "key1,key2,testExcId,Total,Pass,Fail,Executing,NotRun" > "$OUTPUT_CSV"

# Read the input CSV file line by line, skipping the header
tail -n +2 "$INPUT_CSV" | while IFS=, read -r key1 key2; do
    # First API call to get testExcId
    response=$(curl -s -H "Authorization: Bearer $BEARER_TOKEN" "$BASE_URL/rest/raven/1.0/api/testrun?testExecIssueKey=$key1&testIssueKey=$key2")
    testExcId=$(echo "$response" | jq -r '.testExcId')

    if [ "$testExcId" != "null" ]; then
        # Second API call to get test case stats using testExcId
        response=$(curl -s -H "Authorization: Bearer $BEARER_TOKEN" "$BASE_URL/rest/raven/1.0/api/testrun/$testExcId/step")
        
        # Use jq to parse and count the statuses
        total=$(echo "$response" | jq '. | length')
        pass=$(echo "$response" | jq '[.[] | select(.status == "PASS")] | length')
        fail=$(echo "$response" | jq '[.[] | select(.status == "FAIL")] | length')
        executing=$(echo "$response" | jq '[.[] | select(.status == "EXECUTING")] | length')
        notRun=$(echo "$response" | jq '[.[] | select(.status == "NOT_RUN")] | length')

        # Append the data to the output CSV file
        echo "$key1,$key2,$testExcId,$total,$pass,$fail,$executing,$notRun" >> "$OUTPUT_CSV"
        echo "Processed: key1=$key1, key2=$key2, testExcId=$testExcId"
    else
        echo "Error: Failed to get testExcId for key1=$key1, key2=$key2"
    fi
done

echo "Output CSV generated successfully."
