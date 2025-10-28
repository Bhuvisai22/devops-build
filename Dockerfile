# Use Nginx to serve the built React files
FROM nginx:alpine
 
# Copy build output to Nginx's web directory
COPY build /usr/share/nginx/html
 
# Expose port 80
EXPOSE 80
 
# Run Nginx
CMD ["nginx", "-g", "daemon off;"]
