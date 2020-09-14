FROM node:latest as build
COPY . . 
RUN npm install && npm run build

FROM nginx:latest
COPY --from=build ./build /usr/share/nginx/html