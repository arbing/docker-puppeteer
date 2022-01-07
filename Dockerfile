# https://github.com/schliflo/docker-puppeteer/blob/main/Dockerfile
FROM schliflo/docker-puppeteer:latest

# 安装微软字体
ADD ./fonts /usr/share/fonts/msfonts

RUN yarn global add pm2 \
    && yarn cache clean \
    && mkdir -p /app \
    && chmod -R 777 /app
