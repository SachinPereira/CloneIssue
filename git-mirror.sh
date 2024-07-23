#!/bin/sh -e

SOURCE_REPO=$1
SOURCE_TOKEN=$2
DESTINATION_REPO=$3
DESTINATION_TOKEN=$4
FOLLOW_TAGS=$5
DRY_RUN=$6

# Add the token to the source and destination URLs
SOURCE_DIR=$(basename "$SOURCE_REPO")
if [ -z "$SOURCE_TOKEN"]
then
    SOURCE_REPO="https://${SOURCE_TOKEN}@${SOURCE_REPO#https://}"
fi

DESTINATION_REPO="https://${DESTINATION_TOKEN}@${DESTINATION_REPO#https://}"

# Debug outputs
echo "UPDATED SOURCE=$SOURCE_REPO"
echo "UPDATED_DESTINATION=$DESTINATION_REPO"
echo "DRY RUN=$DRY_RUN"

# Execute
git clone --mirror "$SOURCE_REPO" "$SOURCE_DIR" && cd "$SOURCE_DIR"
git remote add mirror "$DESTINATION_REPO"

GIT_PUSH_COMMAND='git push mirror'

if [ "$DRY_RUN" = "true" ]
then
    GIT_PUSH_COMMAND=$GIT_PUSH_COMMAND' --dry-run'
fi

if [ "$FOLLOW_TAGS" = "true" ]
then
    GIT_PUSH_COMMAND=$GIT_PUSH_COMMAND' --follow-tags'
fi

GIT_PUSH_COMMAND=$GIT_PUSH_COMMAND' '$branch
eval $GIT_PUSH_COMMAND

git push --mirror mirror

# Clean up
rm -rf "../$SOURCE_DIR"
