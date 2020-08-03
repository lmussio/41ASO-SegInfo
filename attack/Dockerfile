FROM ubuntu:20.04

RUN apt-get update && apt-get install -y iputils-ping telnet vim tcpdump sqlmap git curl sudo locales && \
    sed -i -e 's/# pt_BR.UTF-8 UTF-8/pt_BR.UTF-8 UTF-8/' /etc/locale.gen && \
    rm -rf /var/lib/apt/lists/*

ENV TZ=America/Sao_Paulo
RUN echo "LC_ALL=pt_BR.UTF-8" >> /etc/environment && echo "pt_BR.UTF-8 UTF-8" >> /etc/locale.gen && echo "LANG=pt_BR.UTF-8" > /etc/locale.conf && locale-gen pt_BR.UTF-8
ENV LC_ALL='pt_BR.UTF-8' LANG='pt_BR.UTF-8' LANGUAGE='pt_BR:pt'
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt update && apt install -y nodejs libcurl4 libcurl4-openssl-dev ruby-full build-essential openssl libreadline6-dev zlib1g zlib1g-dev libssl-dev libyaml-dev libsqlite3-0 libsqlite3-dev sqlite3 libxml2-dev libxslt1-dev autoconf libc6-dev libncurses5-dev automake libtool bison subversion
RUN gem install bundler

WORKDIR /opt/beef/

RUN git init && git remote add origin https://github.com/beefproject/beef && \
    git fetch --depth 1 origin 36bd907f9940d150f188c0f2fb37c7c6535f5255 && \
    git checkout FETCH_HEAD
RUN bundle install

WORKDIR /home/root/