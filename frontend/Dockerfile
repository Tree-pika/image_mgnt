# --- 构建阶段 ---
FROM node:20-bullseye-slim AS build-stage
WORKDIR /app
COPY package*.json ./
# 使用淘宝源安装依赖
RUN npm config set registry https://registry.npmmirror.com
RUN npm install
COPY . .
RUN npm run build

# --- 生产阶段 (Nginx) ---
FROM nginx:stable-alpine AS production-stage
COPY --from=build-stage /app/dist /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]