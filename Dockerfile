FROM node:18-alpine AS build

WORKDIR /app
COPY . .

RUN npm install
RUN npm run build


FROM nginx:stable-alpine
RUN apk add --no-cache curl unzip \
    && curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
    && unzip awscliv2.zip \
    && ./aws/install \
    && rm -rf awscliv2.zip aws

RUN rm -rf /usr/share/nginx/html/*


COPY --from=build /app/build /usr/share/nginx/html


EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
