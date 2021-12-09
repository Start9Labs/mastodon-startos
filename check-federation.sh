#!/bin/bash

# set -e

curl_result=$(curl -s http://mastodon.embassy:3000)
exit_code=$?

if [[ "$exit_code" == 0 ]]; then
    exit 0
else
    echo "Starting up. This may take a few minutes if this is the first time you've started Mastodon." >&2
    exit 61
fi

exit $exit_code
