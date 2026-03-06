#!/bin/sh
echo "🦀 nginx-webs startup — $(date)"

WEBS_DIR="/var/webs"
GITHUB_TOKEN="${GITHUB_TOKEN}"
OK=0; SKIP=0; FAIL=0; FIX=0

# Download fresh webs.txt from GitHub (bypasses Docker cache)
echo "Downloading fresh webs.txt..."
curl -s -H "Authorization: token $GITHUB_TOKEN" -H "Accept: application/vnd.github.v3.raw"     "https://api.github.com/repos/magranero/webs67-nginx/contents/webs.txt" > /tmp/webs.txt
LINES=$(wc -l < /tmp/webs.txt)
echo "Got $LINES entries"

while IFS='|' read -r sub repo; do
    [ -z "$sub" ] && continue
    echo "$sub" | grep -q '^#' && continue
    
    mkdir -p "$WEBS_DIR/$sub"
    
    # Check if file exists AND is valid HTML (contains <html)
    if [ -f "$WEBS_DIR/$sub/index.html" ] && grep -qi '<html' "$WEBS_DIR/$sub/index.html" 2>/dev/null; then
        SKIP=$((SKIP+1))
        continue
    fi
    
    # Remove corrupt file if exists
    if [ -f "$WEBS_DIR/$sub/index.html" ]; then
        echo "  🔄 $sub: corrupt, re-downloading..."
        rm -f "$WEBS_DIR/$sub/index.html"
        FIX=$((FIX+1))
    fi
    
    HTTP_CODE=$(curl -s -w "%{http_code}" -o "$WEBS_DIR/$sub/index.html"         -H "Authorization: token $GITHUB_TOKEN"         -H "Accept: application/vnd.github.v3.raw"         "https://api.github.com/repos/magranero/$repo/contents/index.html")
    
    if [ "$HTTP_CODE" = "200" ] && [ -s "$WEBS_DIR/$sub/index.html" ]; then
        OK=$((OK+1))
        echo "  ✅ $sub"
    else
        rm -f "$WEBS_DIR/$sub/index.html"
        echo "  ❌ $sub (HTTP $HTTP_CODE)"
        FAIL=$((FAIL+1))
    fi
done < /tmp/webs.txt

echo "✅ New: $OK | 🔄 Fixed: $FIX | ⏭️ Existing: $SKIP | ❌ Failed: $FAIL"
echo "Starting nginx..."
cp /app/nginx.conf /etc/nginx/nginx.conf
exec nginx -g "daemon off;"
