# Use Node.js base image
FROM node:18-alpine

# Create app directory
WORKDIR /app

# Copy dependencies and install
COPY package*.json ./
RUN npm install

# Copy app files
COPY . .

# Expose port
EXPOSE 3000

# Start the app
CMD ["node", "server.js"]
