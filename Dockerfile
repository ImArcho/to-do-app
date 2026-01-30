FROM node:18-alpine
WORKDIR /app
COPY package.json yarn.lock ./
RUN yarn install
COPY . .
RUN mkdir -p /tmp/todos
CMD ["yarn", "test"]
