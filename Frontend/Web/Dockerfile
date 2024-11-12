# Frontend/Web/Dockerfile
FROM node:18-alpine

WORKDIR /web

COPY package*.json ./
RUN npm install

COPY . .

RUN npm run build

FROM nginx:alpine
COPY --from=0 /web/dist /usr/share/nginx/html

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
