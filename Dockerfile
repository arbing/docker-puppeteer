# https://github.com/schliflo/docker-puppeteer/blob/main/Dockerfile
FROM schliflo/docker-puppeteer:latest

# 安装微软字体
ADD ./fonts /usr/share/fonts/msfonts

RUN npm i pm2 -g \
    && pm2 install pm2-logrotate \
    && pm2 set pm2-logrotate:max_size 100M \
    && pm2 set pm2-logrotate:retain 100 \
    && mkdir -p /app \
    && chmod -R 777 /app \
    && cd /app
