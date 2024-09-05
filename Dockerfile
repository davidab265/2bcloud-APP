# Use the official Node.js 18 image as the base image
FROM node:21-alpine

# Set the working directory inside the container
WORKDIR /app

# Copy the package.json and package-lock.json (or yarn.lock) files
COPY . .
# Install dependencies
RUN npm install

# Copy the rest of the application code

# Expose the port that the app will run on
EXPOSE 3000

# Run the Angular app
CMD ["npm", "start", "--", "--host", "0.0.0.0", "--disable-host-check", "--no-open"]