# Use an official Nginx image
FROM nginx:alpine

# Copy static website files to the container
COPY ./finexo-html/ /usr/share/nginx/html

# Expose port 80
EXPOSE 80

# Run Nginx in the foreground
CMD ["nginx", "-g", "daemon off;"]

