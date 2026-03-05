#!/bin/sh
echo "🦀 nginx-webs startup — $(date)"

WEBS_DIR="/var/webs"
GITHUB_TOKEN="${GITHUB_TOKEN}"
OK=0; SKIP=0; FAIL=0

while IFS='|' read -r sub repo; do
    [ -z "$sub" ] && continue
    echo "$sub" | grep -q '^#' && continue
    
    if [ -f "$WEBS_DIR/$sub/index.html" ]; then
        SKIP=$((SKIP+1))
        continue
    fi
    
    mkdir -p "$WEBS_DIR/$sub"
    
    # Download raw file from GitHub
    HTTP_CODE=$(curl -s -w "%{http_code}" -o "$WEBS_DIR/$sub/index.html" \
        -H "Authorization: token $GITHUB_TOKEN" \
        -H "Accept: application/vnd.github.v3.raw" \
        "https://api.github.com/repos/magranero/$repo/contents/index.html")
    
    if [ "$HTTP_CODE" = "200" ] && [ -s "$WEBS_DIR/$sub/index.html" ]; then
        OK=$((OK+1))
        echo "  ✅ $sub"
    else
        rm -f "$WEBS_DIR/$sub/index.html"
        echo "  ❌ $sub (HTTP $HTTP_CODE)"
        FAIL=$((FAIL+1))
    fi
done < /app/webs.txt

echo "✅ New: $OK | ⏭️ Existing: $SKIP | ❌ Failed: $FAIL"
echo "Starting nginx..."
exec nginx -g "daemon off;"
