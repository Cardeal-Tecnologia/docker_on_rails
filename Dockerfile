# syntax=docker/dockerfile:1
FROM ruby:3.1.2

# Install Postgresql 14
RUN apt-get update -y
RUN apt install curl ca-certificates gnupg libzmq5-dev -y
RUN curl https://www.postgresql.org/media/keys/ACCC4CF8.asc \
          | gpg --dearmor \
          | tee /etc/apt/trusted.gpg.d/apt.postgresql.org.gpg >/dev/null
RUN sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/ bullseye-pgdg main" > /etc/apt/sources.list.d/postgresql.list'
RUN apt update
RUN apt-get -y install postgresql-14

# Install node
RUN curl -sL https://deb.nodesource.com/setup_16.x -o /tmp/nodesource_setup.sh
RUN bash /tmp/nodesource_setup.sh
RUN apt install nodejs -y

# Install yarn
RUN npm install -g yarn

WORKDIR /app
COPY . /app
COPY Gemfile Gemfile
COPY Gemfile.lock Gemfile.lock
COPY /bin/docker-entrypoint.sh /app/bin/docker-entrypoint.sh
RUN bundle install
RUN yarn install



RUN chmod a+rwx bin/docker-entrypoint.sh
# Add a script to be executed every time the container starts.
EXPOSE 3000
ENTRYPOINT ["/app/bin/docker-entrypoint.sh"]

RUN rails db:migrate
# Configure the main process to run when running the image
CMD ["rails", "server", "-b", "0.0.0.0"]    