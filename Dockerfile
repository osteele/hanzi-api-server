FROM node:18-alpine

# Create app directory
WORKDIR /usr/src/app

# Copy the package.json and yarn.lock files
COPY package.json yarn.lock ./

# Install dependencies
RUN yarn install --only=production

# Copy the rest of the application files
COPY . .

# Set the environment variable
ENV NODE_ENV=production

# Build the application
RUN yarn build

# Expose port and start server
ENV PORT=3000
EXPOSE 3000
CMD ["yarn", "start"]
