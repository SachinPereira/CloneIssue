#!/bin/sh -e

SOURCE_REPO=$1
SOURCE_TOKEN=$2
DESTINATION_REPO=$3
DESTINATION_TOKEN=$4
FOLLOW_TAGS=$5
DRY_RUN=$6

# Add the token to the source and destination URLs
SOURCE_DIR=$(basename "$SOURCE_REPO")
if [ -n "$SOURCE_TOKEN" ]
then
    SOURCE_REPO="https://${SOURCE_TOKEN}@${SOURCE_REPO#https://}"
fi

DESTINATION_REPO="https://${DESTINATION_TOKEN}@${DESTINATION_REPO#https://}"

# Debug outputs
echo "UPDATED SOURCE=$SOURCE_REPO"
echo "UPDATED DESTINATION=$DESTINATION_REPO"
echo "DRY RUN=$DRY_RUN"

# Execute
git clone --mirror "$SOURCE_REPO" "$SOURCE_DIR" && cd "$SOURCE_DIR"
git remote add mirror "$DESTINATION_REPO"
git fetch -p mirror

# Fetch all tags explicitly
git fetch origin --tags

# Push all refs and tags to the new remote
GIT_PUSH_COMMAND='git push mirror --all'

if [ "$DRY_RUN" = "true" ]
then
    GIT_PUSH_COMMAND="$GIT_PUSH_COMMAND --dry-run"
fi

if [ "$FOLLOW_TAGS" = "true" ]
then
    GIT_PUSH_COMMAND="$GIT_PUSH_COMMAND --follow-tags"
else
    # Push tags separately if FOLLOW_TAGS is not true
    GIT_PUSH_COMMAND="$GIT_PUSH_COMMAND && git push mirror --tags"
fi

eval $GIT_PUSH_COMMAND

# Clean up
cd ..
rm -rf "$SOURCE_DIR"
