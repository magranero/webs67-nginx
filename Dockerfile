FROM nginx:alpine
RUN apk add --no-cache curl
WORKDIR /app
COPY webs.txt startup.sh nginx.conf ./
RUN chmod +x startup.sh
CMD ["/app/startup.sh"]
