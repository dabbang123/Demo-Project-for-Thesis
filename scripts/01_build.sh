#!/usr/bin/env bash
set -euo pipefail
echo "[01] Maven build (Spring Boot)"
MVN="./mvnw"
[[ -x "$MVN" ]] || MVN="mvn"
SKIP="${SKIP_TESTS:-true}"
"$MVN" -B -DskipTests="${SKIP}" clean package
