FROM nginx:alpine
RUN apk add --no-cache curl jq && echo "cache-bust-1772821742"
WORKDIR /app
COPY webs.txt startup.sh nginx.conf ./
RUN chmod +x startup.sh
CMD ["/app/startup.sh"]
