FROM ruby:2.2

# Install dependencies
RUN apt-get update && apt-get install -y \
  build-essential \
  fontconfig \
  locales \
  zlib1g-dev \
  xvfb \
  libxcomposite1 \
  libasound2 \
  libdbus-glib-1-2 \
  libgtk2.0-0 \
  && apt-get clean \
   && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Generate UTF-8 locale
RUN dpkg-reconfigure locales && \
  locale-gen C.UTF-8 && \
  /usr/sbin/update-locale LANG=C.UTF-8 && \
  echo 'en_US.UTF-8 UTF-8' >> /etc/locale.gen && locale-gen

# set env variables
ENV LC_ALL C.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8
ENV DISPLAY=":99.0"
ENV FF_VERSION="42.0"

RUN wget -q "https://download-installer.cdn.mozilla.net/pub/firefox/releases/${FF_VERSION}/linux-x86_64/en-US/firefox-${FF_VERSION}.tar.bz2" \
    -O /tmp/firefox.tar.bz2 && \
    tar xvf /tmp/firefox.tar.bz2 -C /opt && \
    ln -s /opt/firefox/firefox /usr/bin/firefox && \
    rm -rf /tmp/*

# Install Xvfb init script
ADD xvfb_init /etc/init.d/xvfb
RUN chmod a+x /etc/init.d/xvfb
ADD xvfb-daemon-run /usr/bin/xvfb-daemon-run
RUN chmod a+x /usr/bin/xvfb-daemon-run

RUN mkdir -p /specs
WORKDIR /specs

COPY Gemfile Gemfile.lock ./
RUN gem install bundler \
  && bundle install --jobs 20 --retry 5

CMD ["/usr/bin/xvfb-daemon-run", "rspec"]
