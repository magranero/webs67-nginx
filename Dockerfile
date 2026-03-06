FROM nginx:alpine
RUN apk add --no-cache curl jq grep
COPY nginx.conf /etc/nginx/nginx.conf
ENV GITHUB_TOKEN=""
# Download and run startup.sh from GitHub at runtime (never cached)
CMD ["sh", "-c", "curl -sL -H \"Authorization: token $GITHUB_TOKEN\" -H \"Accept: application/vnd.github.v3.raw\" https://api.github.com/repos/magranero/webs67-nginx/contents/startup.sh > /tmp/startup.sh && chmod +x /tmp/startup.sh && /tmp/startup.sh"]
