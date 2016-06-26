FROM ruby:2.3.1-alpine

RUN apk add --no-cache nodejs

# PhantomJS is required for running tests
ENV PHANTOMJS_VERSION 2.1.1
ENV PHANTOMJS_SHA256 86dd9a4bf4aee45f1a84c9f61cf1947c1d6dce9b9e8d2a907105da7852460d2f

RUN curl -o phantomjs.tar.bz2 -f -sSL "https://bitbucket.org/ariya/phantomjs/downloads/phantomjs-$PHANTOMJS_VERSION-linux-x86_64.tar.bz2" \
  && echo "$PHANTOMJS_SHA256 *phantomjs.tar.bz2" | sha256sum -c - \
  && tar -xjf phantomjs.tar.bz2 -C /usr/local \
  && mv "/usr/local/phantomjs-$PHANTOMJS_VERSION-linux-x86_64" /usr/local/phantomjs \
  && rm phantomjs.tar.bz2

RUN ln -s ../phantomjs/bin/phantomjs /usr/local/bin/

WORKDIR /ohana-web-search

COPY Gemfile /ohana-web-search
COPY Gemfile.lock /ohana-web-search

RUN bundle install

COPY . /ohana-web-search

EXPOSE 3000
CMD ["rails", "server", "-b", "0.0.0.0"]
