FROM ruby:3.3.12

ENV NODE_MAJOR=26

# https://github.com/nodesource/distributions#installation-instructions
RUN apt-get update && \
    apt-get install -y ca-certificates curl gnupg && \
    mkdir -p /etc/apt/keyrings &&  \
    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg && \
    echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list && \
    apt-get update && \
    apt-get install nodejs -y

RUN apt-get update && apt-get install -y \
    vim \
    htop

ENV APP_PATH="App"
WORKDIR /$APP_PATH

# Remove any tmp/pids/server.pid with every container start up
COPY entrypoint.sh /$APP_PATH
RUN cp /$APP_PATH/entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]

RUN mkdir /$APP_PATH/bin

CMD ["/bin/bash"]
