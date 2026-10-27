#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

VERSION="${1:-dev}"
OUTPUT_DIR="${2:-$REPO_ROOT/dist}"
SRC_DIR="$REPO_ROOT/src"

OSF_NAME="CleanOsmand-${VERSION}.osf"
BUILD_DIR="$(mktemp -d)"
trap 'rm -rf "$BUILD_DIR"' EXIT

echo "==> Building $OSF_NAME"
echo "    Source: $SRC_DIR"
echo "    Output: $OUTPUT_DIR/$OSF_NAME"

mkdir -p "$OUTPUT_DIR"

cp -r "$SRC_DIR"/* "$BUILD_DIR"/

sed -i.bak "s/\"version\" : 1/\"version\" : ${VERSION}/g" "$BUILD_DIR/items.json" 2>/dev/null || \
  sed -i "s/\"version\" : 1/\"version\" : ${VERSION}/g" "$BUILD_DIR/items.json"
rm -f "$BUILD_DIR/items.json.bak"

sed -i.bak "s/CleanOsmand v1:/CleanOsmand ${VERSION}:/g" "$BUILD_DIR/items.json" 2>/dev/null || \
  sed -i "s/CleanOsmand v1:/CleanOsmand ${VERSION}:/g" "$BUILD_DIR/items.json"
rm -f "$BUILD_DIR/items.json.bak"

sed -i.bak "s/<renderingStyle name=\"CleanOsmand\"/<renderingStyle name=\"CleanOsmand ${VERSION}\"/g" "$BUILD_DIR/rendering/CleanOsmand.render.xml" 2>/dev/null || \
  sed -i "s/<renderingStyle name=\"CleanOsmand\"/<renderingStyle name=\"CleanOsmand ${VERSION}\"/g" "$BUILD_DIR/rendering/CleanOsmand.render.xml"
rm -f "$BUILD_DIR/rendering/CleanOsmand.render.xml.bak"

cd "$BUILD_DIR"
rm -f "$OUTPUT_DIR/$OSF_NAME"
zip -r -X "$OUTPUT_DIR/$OSF_NAME" . -x '**/.DS_Store' -x '.DS_Store'

echo "==> Created: $OUTPUT_DIR/$OSF_NAME"
echo "==> Contents:"
unzip -l "$OUTPUT_DIR/$OSF_NAME"
