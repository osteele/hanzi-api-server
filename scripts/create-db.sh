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
    curl -s "$URL" \
      | awk '/<pre>/,/<\/pre>/ {if (NF==10 && ++count>1) print}' \
      > "$TSV_FILE"
      # | awk -F'\t' 'NR>1 && $1==prev {print prev_line} {prev=$1; prev_line=$0}' \
fi

# If the SQLite database file already exists, remove it
if [ -f "$DB_FILE" ]; then
  rm "$DB_FILE"
fi

# Create a new SQLite database file
sqlite3 "$DB_FILE" <<EOF
CREATE TABLE decompositions (
  component CHAR(1) PRIMARY KEY,
  strokes INTEGER CHECK (strokes > 0) NOT NULL,
  decompositionType TEXT, -- CHECK (decompositionType IN ('*', '+', '一', '冖', '叕', '吅', '吕', '咒', '品', '回', '弼')) NOT NULL,
  leftComponent CHAR(1) NOT NULL,
  leftStrokes INTEGER CHECK (leftStrokes >= 0) NOT NULL,
  rightComponent CHAR(1),
  rightStrokes INTEGER CHECK (rightStrokes >= 0),
  signature VARCHAR(5), -- CHECK (signature REGEXP '^[A-Z]{1,5}$|^1$') NOT NULL,
  notes TEXT CHECK (notes IN ('*/', '*/*', '*/?', '/', '/#REF!', '/*', '/?', '?/', '?/?')) NOT NULL,
  radical CHAR(1)
);
.mode tabs
.import "$TSV_FILE" decompositions
UPDATE decompositions SET rightStrokes = NULL WHERE rightStrokes = 0;
UPDATE decompositions SET rightComponent = NULL WHERE rightComponent = '*';
UPDATE decompositions SET radical = component WHERE radical = '*';
CREATE INDEX leftCompIndex ON decompositions(leftComponent);
CREATE INDEX rightCompIndex ON decompositions(rightComponent);
EOF
