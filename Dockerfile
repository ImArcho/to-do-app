FROM node:20-alpine

WORKDIR /app

COPY app/package.json app/yarn.lock ./

RUN yarn install --frozen-lockfile

COPY app/ .

CMD ["node", "src/index.js"]
