# 使用官方 Python 镜像
FROM python:3.10-slim-bullseye

# 设置工作目录
WORKDIR /app

# 清华大学Debian 源
# RUN sed -i 's/deb.debian.org/mirrors.tuna.tsinghua.edu.cn/g' /etc/apt/sources.list \
#     && sed -i 's/security.debian.org/mirrors.tuna.tsinghua.edu.cn/g' /etc/apt/sources.list
RUN sed -i 's/deb.debian.org/mirrors.aliyun.com/g' /etc/apt/sources.list \
    && sed -i 's/security.debian.org/mirrors.aliyun.com/g' /etc/apt/sources.list

# 安装系统依赖
# 1. libgl1-mesa-glx, libglib2.0-0 是 OpenCV (处理图片) 需要的
# 2. pkg-config, default-libmysqlclient-dev, build-essential 是 mysqlclient 编译需要的
RUN apt-get update && apt-get install -y \
    libgl1-mesa-glx \
    libglib2.0-0 \
    pkg-config \
    default-libmysqlclient-dev \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# 设置环境变量
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
# 强制让 transformers 使用镜像站
ENV HF_ENDPOINT=https://hf-mirror.com

# 复制依赖文件
COPY requirements.txt .

# 安装 Python 依赖
# 生成 requirements.txt
RUN pip install --no-cache-dir -r requirements.txt -i https://pypi.tuna.tsinghua.edu.cn/simple

# 复制项目代码
COPY . .

# 暴露端口
EXPOSE 8000

# 启动命令
CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]