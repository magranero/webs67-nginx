FROM nginx:alpine
RUN apk add --no-cache curl
WORKDIR /app
COPY webs.txt startup.sh nginx.conf ./
RUN chmod +x startup.sh
RUN cp /app/nginx.conf /etc/nginx/nginx.conf
CMD ["/app/startup.sh"]

# cache-bust-1772793814
