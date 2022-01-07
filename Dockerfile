# https://github.com/schliflo/docker-puppeteer/blob/main/Dockerfile
FROM schliflo/docker-puppeteer:latest

# 安装微软字体
ADD ./fonts /usr/share/fonts/msfonts
