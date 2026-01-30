FROM node:18-alpine AS app-base
WORKDIR /app

# Копируем package.json и yarn.lock из папки app
COPY app/package.json app/yarn.lock ./

# Устанавливаем зависимости
RUN yarn install

# Копируем остальные файлы из папки app
COPY app/ ./

# Создаем директорию для тестов
RUN mkdir -p /tmp/todos

# Запускаем тесты
CMD ["yarn", "test"]
