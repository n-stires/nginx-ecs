FROM nginx:stable

# Copy nginx server config
COPY server/conf/* /etc/nginx/conf.d/

# Copy webroot
COPY server/www/* /usr/share/nginx/html/
