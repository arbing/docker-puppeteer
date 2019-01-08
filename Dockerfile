FROM node:lts-slim

# See https://crbug.com/795759
RUN apt-get update && apt-get install -yq libgconf-2-4

# Install latest chrome dev package and fonts to support major charsets (Chinese, Japanese, Arabic, Hebrew, Thai and a few others)
# Note: this installs the necessary libs to make the bundled version of Chromium that Puppeteer
# installs, work.
RUN apt-get update && apt-get install -y wget --no-install-recommends \
    && wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
    && sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list' \
    && sh -c 'echo "deb http://deb.debian.org/debian unstable main contrib non-free" >> /etc/apt/sources.list' \
    && sh -c 'echo "deb http://deb.debian.org/debian stable main contrib non-free" >> /etc/apt/sources.list' \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
      google-chrome-unstable \
      fonts-ipafont-gothic \
      fonts-wqy-zenhei \
      fonts-thai-tlwg \
      fonts-kacst ttf-freefont \
    && apt-get -t unstable install \
        fonts-noto-color-emoji \
    && rm -rf /src/*.deb \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get purge --auto-remove -y curl \
    && rm -f /etc/apt/sources.list.d/google.list

# 安装微软字体
ADD ./fonts /usr/share/fonts/msfonts

# It's a good idea to use dumb-init to help prevent zombie chrome processes.
ADD https://github.com/Yelp/dumb-init/releases/download/v1.2.0/dumb-init_1.2.0_amd64 /usr/local/bin/dumb-init
RUN chmod +x /usr/local/bin/dumb-init

# Uncomment to skip the chromium download when installing puppeteer. If you do,
# you'll need to launch puppeteer with:
#     browser.launch({executablePath: 'google-chrome-unstable'})
# ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD true

# Install puppeteer so it's available in the container.
#RUN npm i puppeteer

RUN npm i pm2 -g \
    && pm2 install pm2-logrotate \
    && pm2 set pm2-logrotate:max_size 100M \
    && pm2 set pm2-logrotate:retain 100 \
    && mkdir -p /app \
    && chmod -R 777 /app \
    && cd /app \
    && npm i puppeteer --no-save --no-package-lock \
    && npm cache clean --force

# Add user so we don't need --no-sandbox.
RUN groupadd -r pptruser \
    && useradd -r -g pptruser -G audio,video pptruser \
    && mkdir -p /home/pptruser/Downloads \
    && chown -R pptruser:pptruser /home/pptruser \
    && chown -R pptruser:pptruser /app/node_modules

# --cap-add=SYS_ADMIN
# https://docs.docker.com/engine/reference/run/#additional-groups

# Run everything after as non-privileged user.
USER pptruser

ENTRYPOINT ["dumb-init", "--"]

CMD ["google-chrome-unstable"]
