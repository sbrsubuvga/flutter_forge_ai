FROM node:20-alpine AS base
WORKDIR /app
COPY package.json package-lock.json* ./
RUN npm install --omit=dev || npm install

COPY . .
RUN npm install --save-dev typescript tsx && npm run build

EXPOSE 4000
CMD ["node", "dist/index.js"]
