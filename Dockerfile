FROM ruby:2.3.1-alpine

RUN apk add --no-cache nodejs tzdata

# PhantomJS is required for running tests
ENV PHANTOMJS_VERSION 2.1.1
ENV PHANTOMJS_SHA256 86dd9a4bf4aee45f1a84c9f61cf1947c1d6dce9b9e8d2a907105da7852460d2f

# Install runtime dependencies for phantomjs
RUN apk add --no-cache --virtual .phantomjs-rundeps \
    fontconfig \
    libc6-compat

RUN curl -o phantomjs.tar.bz2 -f -sSL "https://bitbucket.org/ariya/phantomjs/downloads/phantomjs-$PHANTOMJS_VERSION-linux-x86_64.tar.bz2" \
  && echo "$PHANTOMJS_SHA256 *phantomjs.tar.bz2" | sha256sum -c - \
  && tar -xjf phantomjs.tar.bz2 -C /usr/local \
  && mv "/usr/local/phantomjs-$PHANTOMJS_VERSION-linux-x86_64" /usr/local/phantomjs \
  && rm phantomjs.tar.bz2

RUN ln -s ../phantomjs/bin/phantomjs /usr/local/bin/

WORKDIR /ohana-web-search

COPY Gemfile /ohana-web-search
COPY Gemfile.lock /ohana-web-search

# Install runtime libraries needed for Nokogiri and configure it to use them
RUN apk add --no-cache --virtual .ohana-rundeps \
    libxml2 \
    libxslt \
  && bundle config build.nokogiri --use-system-libraries

# Install gcc and other build-time dependencies to allow bundler to build native extensions, then remove them after bundle install
RUN apk add --no-cache --virtual .ohana-builddeps \
    build-base \
    libxml2-dev \
    libxslt-dev \
  && bundle install \
  && apk del .ohana-builddeps

COPY . /ohana-web-search

EXPOSE 3000
CMD ["rails", "server", "-b", "0.0.0.0"]
