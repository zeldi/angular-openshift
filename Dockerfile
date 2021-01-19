# stage 1
FROM node:latest as node
WORKDIR /app
COPY . .
RUN npm install
ARG env=prod
RUN npm run build --prod

# stage 2
# FROM nginx:alpine
FROM image-registry.openshift-image-registry.svc:5000/test-app/nginx:alpine

RUN adduser node

COPY --from=node /app/dist/ /usr/share/nginx/html
COPY --from=node /app/default.conf /etc/nginx/conf.d/

EXPOSE 8080
