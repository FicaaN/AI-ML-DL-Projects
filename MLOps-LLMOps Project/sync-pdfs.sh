#!/bin/bash
# sync-pdfs.sh

BRANCH="igor"
REPO_PATH="."  # Root of the repo
PDF_FOLDER="MLOps-LLMOps Project/pdfs"  # Path to PDFs inside repo
CHECK_INTERVAL=30  # 5 minutes (in seconds)

echo "📡 Starting PDF sync monitor for branch: $BRANCH"
echo "⏱️  Check interval: ${CHECK_INTERVAL}s"

cd $REPO_PATH

while true; do
    echo ""
    echo "🔍 Checking for updates..."

    git fetch origin $BRANCH

    LOCAL=$(git rev-parse HEAD)
    REMOTE=$(git rev-parse origin/$BRANCH)

    if [ $LOCAL != $REMOTE ]; then
        # Check for PDF changes in specific folder
        echo "DEBUG - All changed files:"

        PDF_CHANGES=$(git diff --name-only $LOCAL $REMOTE | grep "^$PDF_FOLDER/.*\.pdf$")

        echo "$PDF_CHANGES"

        if [ -n "$PDF_CHANGES" ]; then
            echo "📄 PDF changes detected:"
            echo "$PDF_CHANGES"

            echo "📥 Pulling changes..."
            git pull origin $BRANCH

            echo "🚀 Restarting ingestion..."
            
            docker-compose up -d --no-deps --build ingestion

            echo "✅ Ingestion restarted"
        else
            echo "ℹ️  New commits, but no PDF changes"
            git pull origin $BRANCH
        fi
    else
        echo "$PDF_CHANGES"
        echo "✅ No updates"
    fi

    echo "💤 Sleeping for ${CHECK_INTERVAL}s..."
    sleep $CHECK_INTERVAL
done