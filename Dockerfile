FROM jekyll/jekyll

WORKDIR /srv/jekyll

COPY --chown=jekyll:jekyll Gemfile Gemfile.lock ./


RUN gem install bundler -v 2.6.5 --no-document

USER jekyll

RUN bundle config set path 'vendor/bundle' \
  && bundle config set deployment true \
  && bundle config set frozen true \
  && bundle install --jobs=4 --retry=3

COPY --chown=jekyll:jekyll . .

EXPOSE 4000

CMD ["jekyll", "serve", "--host", "0.0.0.0"]