# Dockerfile
FROM ruby:3.1.4

# 必要なパッケージのインストール
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs

# アプリケーションディレクトリの作成
RUN mkdir /myapp
WORKDIR /myapp

# GemfileとGemfile.lockをコピー
COPY Gemfile /myapp/Gemfile
COPY Gemfile.lock /myapp/Gemfile.lock

# 必要なRubyGemsのインストール
RUN gem install bundler:2.3.7
RUN bundle install

# アプリケーションのソースコードをコピー
COPY . /myapp
