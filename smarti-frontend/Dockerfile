# Build stage
FROM node:20-alpine AS build

# Install build dependencies
WORKDIR /app
# Copy package files first for better caching
COPY package*.json ./
RUN npm ci --silent

# Copy source and build
COPY . .
# Ensure environment is production
ENV NODE_ENV=production
# Build the Angular app (uses default production configuration)
RUN npm run build -- --configuration production

# Production stage - nginx
FROM nginx:stable-alpine AS production

# Remove default nginx config and replace with SPA-friendly config
RUN rm /etc/nginx/conf.d/default.conf
RUN cat > /etc/nginx/conf.d/default.conf <<'EOF'
server {
  listen 80;
  server_name _;

  root /usr/share/nginx/html;
  index index.html;

  # Serve static files directly, fallback to index.html for SPA routes
  location / {
    try_files $uri $uri/ /index.html;
  }

  # Long caching for hashed assets
  location ~* \.(?:js|css|png|jpg|jpeg|gif|ico|svg|eot|ttf|woff|woff2)$ {
    try_files $uri =404;
    expires 1y;
    add_header Cache-Control "public, max-age=31536000, immutable";
  }

  # Optional: reduce logging for cleaner output
  access_log off;
}
EOF

# Copy built files from the build stage
COPY --from=build /app/dist/smarti-frontend/browser/ /usr/share/nginx/html/

# Expose port 80 and run nginx in foreground
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
