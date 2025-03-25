#!/bin/bash

PATTERNS=("GradleDaemon" "KotlinCompileDaemon" "GradleWorkerMain")
LOG_FILE="/tmp/java_mem_monitor.log"
INTERVAL=5

echo "Starting memory monitor at $(date)" > "$LOG_FILE"
echo "Timestamp | PID | Name | Heap_Used_MB | Heap_Capacity_MB | RSS_MB" >> "$LOG_FILE"

while true; do
  TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")

  jps_output=$(jps)

  while IFS= read -r line; do
    PID=$(echo "$line" | awk '{print $1}')
    NAME=$(echo "$line" | awk '{print $2}')

    for PATTERN in "${PATTERNS[@]}"; do
      if [[ "$NAME" == "$PATTERN" ]]; then
        # Get heap info (column indexes for jstat -gc)
        GC_LINE=$(jstat -gc "$PID" 2>/dev/null | tail -n 1)
        [[ -z "$GC_LINE" ]] && continue

        EC=$(echo "$GC_LINE" | awk '{print $5}')
        EU=$(echo "$GC_LINE" | awk '{print $6}')
        OC=$(echo "$GC_LINE" | awk '{print $7}')
        OU=$(echo "$GC_LINE" | awk '{print $8}')

        # Calculate heap used and capacity (MB)
        HEAP_USED_MB=$(awk "BEGIN { printf \"%.1f\", ($EU + $OU) / 1024 }")
        HEAP_CAP_MB=$(awk "BEGIN { printf \"%.1f\", ($EC + $OC) / 1024 }")

        # Get RSS in KB and convert to MB
        RSS_KB=$(ps -o rss= -p "$PID" 2>/dev/null | tr -d ' ')
        [[ -z "$RSS_KB" ]] && continue
        RSS_MB=$(awk "BEGIN { printf \"%.1f\", $RSS_KB / 1024 }")

        echo "$TIMESTAMP | $PID | $NAME | ${HEAP_USED_MB}MB | ${HEAP_CAP_MB}MB | ${RSS_MB}MB" >> "$LOG_FILE"
      fi
    done

  done <<< "$jps_output"

  sleep $INTERVAL
done
