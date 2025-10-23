# Use Node.js base image
FROM node:18-alpine

# Create app directory
WORKDIR /app

# Copy dependency files and install packages
COPY package*.json ./
RUN npm install --production

# Copy application files
COPY . .

# Expose container port
EXPOSE 3000

# Run the app
CMD ["node", "server.js"]
