#!/bin/bash
# Builds rsyntaxtextarea-3.3.4 with rsyntaxtextarea-3.3.4-wrap.patch applied:
# line wrap of a long token is no longer quadratic in the token length.
#
# usage: build.sh <out.jar>
# The result replaces lib/rsyntaxtextarea-3.3.4.jar of a JMeter 5.6.3 installation.
set -euo pipefail

OUT=$(cd "$(dirname "$1")" && pwd)/$(basename "$1")
HERE=$(cd "$(dirname "$0")" && pwd)
WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT

BASE=https://repo1.maven.org/maven2/com/fifesoft/rsyntaxtextarea/3.3.4
JAR_SHA256=cbcd2167afd58ffce616d9bd2d95c94dd3f951e62486b56462ce0abe3ca6f8ec
SRC_SHA256=644d6598e89a90bb8fdbe762bb708348619a93c1a4e6cefeb490c220561e8adc

cd "$WORK"
curl -sSfo orig.jar "$BASE/rsyntaxtextarea-3.3.4.jar"
curl -sSfo sources.jar "$BASE/rsyntaxtextarea-3.3.4-sources.jar"
echo "$JAR_SHA256  orig.jar" | shasum -a 256 -c -
echo "$SRC_SHA256  sources.jar" | shasum -a 256 -c -

mkdir src classes
(cd src && unzip -q ../sources.jar \
    org/fife/ui/rsyntaxtextarea/WrappedSyntaxView.java \
    org/fife/ui/rsyntaxtextarea/TokenUtils.java \
  && patch -p1 < "$HERE/rsyntaxtextarea-3.3.4-wrap.patch")

javac --release 8 -nowarn -encoding UTF-8 -cp orig.jar -d classes \
    src/org/fife/ui/rsyntaxtextarea/WrappedSyntaxView.java \
    src/org/fife/ui/rsyntaxtextarea/TokenUtils.java

cp orig.jar "$OUT"
(cd classes && jar uf "$OUT" org)
echo "built $OUT"
