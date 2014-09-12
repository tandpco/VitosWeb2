web: bundle exec unicorn -c ./config/unicorn.rb
custom_web: bundle exec thin start --socket /tmp/web_server.sock --pid /tmp/web_server.pid -e $RACK_ENV -d