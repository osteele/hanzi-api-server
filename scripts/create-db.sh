#!/bin/bash

# Define the name of the TSV file and SQLite database
TSV_FILE="data/decompositions.tsv"
DB_FILE="data/decompositions.sqlite"
URL="https://commons.wikimedia.org/wiki/User:Artsakenos/CCD-TSV?action=raw"
FORCE_DOWNLOAD=false

# Parse command-line options
while [[ $# -gt 0 ]]; do
  key="$1"
  case $key in
    -f|--force)
      FORCE_DOWNLOAD=true
      shift # past argument
      ;;
    *)
      echo "Unknown option: $key"
      exit 1
      ;;
  esac
done

# Check if the local file exists
DOWNLOAD=false
if [ -f "$TSV_FILE" ] && [ "$FORCE_DOWNLOAD" = false ]; then
  # Use curl to get the modification date of the remote file
  REMOTE_DATE=$(curl -sI "$URL" | awk -F ': ' '/^Last-Modified:/ {print $2}')

  # Use date command to get the modification date of the local file
  LOCAL_DATE=$(date -r "$TSV_FILE" "+%a, %d %b %Y %H:%M:%S %Z")

  # Compare the two dates to see if the remote file is newer
  if [[ "$REMOTE_DATE" > "$LOCAL_DATE" ]]; then
    DOWNLOAD=true
  fi
else
  DOWNLOAD=true
fi

if [ "$DOWNLOAD" = true ]; then
  # Download the file from the remote URL
    curl -s "$URL" | awk '/<pre>/,/<\/pre>/ {if (NF==10 && ++count>1) print}' > "$TSV_FILE"
fi

# If the SQLite database file already exists, remove it
if [ -f "$DB_FILE" ]; then
  rm "$DB_FILE"
fi

# Create a new SQLite database file
sqlite3 "$DB_FILE" <<EOF
CREATE TABLE decompositions (
  component TEXT,
  strokes NUMBER,
  decompositionType TEXT,
  leftComponent TEXT,
  leftStrokes NUMBER,
  rightComponent TEXT,
  rightStrokes NUMBER,
  signature TEXT,
  notes TEXT,
  section NUMBER
);
.mode tabs
.import "$TSV_FILE" decompositions
EOF
