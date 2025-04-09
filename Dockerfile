FROM node:18-alpine AS build

WORKDIR /app
COPY . .

RUN npm install
RUN npm run build


FROM nginx:stable-alpine

# Install AWS CLI (v2) without Python, with minimal tools
RUN apk add --no-cache curl unzip libc6-compat && \
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    ./aws/install && \
    rm -rf awscliv2.zip aws

# Clean Nginx default files
RUN rm -rf /usr/share/nginx/html/*

# Copy React build
COPY --from=build /app/build /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
