FROM gitpod/workspace-full

USER gitpod

RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/Linuxbrew/install/master/install.sh)"

RUN brew install rbenv && rbenv install 2.7.2 && rbenv global 2.7.2 && gem install railties && rbenv rehash && ruby -v

RUN gem install bundler:2.1.4 && bundle install && brew install postgresql && pg_ctl -D /home/linuxbrew/.linuxbrew/var/postgres start && rbenv exec gem install bundler && bundle exec bundle install --path=./vendor/bundle && RAILS_ENV=development bundle exec rake db:create db:migrate 

