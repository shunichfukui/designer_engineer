FROM node:14-alpine as node

RUN apk update && apk add git

WORKDIR /app

RUN yarn install

EXPOSE 3000

CMD ["yarn", "run", "dev"]