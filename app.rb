require 'rubygems'
require 'bundler'

# Setup load paths
Bundler.require
$: << File.expand_path('../', __FILE__)
$: << File.expand_path('../lib', __FILE__)

require 'dotenv'
Dotenv.load

# Require base
require 'sinatra/base'
require 'sinatra/activerecord'
require 'active_support/core_ext/string'
require 'active_support/core_ext/array'
require 'active_support/core_ext/hash'
require 'active_support/json'
require 'moneta'
require 'rack/session/moneta'

libraries = Dir[File.expand_path('../lib/**/*.rb', __FILE__)]
libraries.each do |path_name|
  require path_name
end

Dir["./deprecated/ViewControllers/*.rb"].sort.each do |file| 
    file.sub!("\.rb","");
    require file
end

require 'app/extensions'
require 'app/models'
require 'app/helpers'
require 'app/routes'
require 'slim'
# require 'slim/include'
require 'warden'

module Vitos
  class App < Sinatra::Application
    configure :production, :development do
      db = URI.parse(ENV['DATABASE_URL'])
 
      ActiveRecord::Base.establish_connection(
          :adapter  => db.scheme,
          :host     => db.host,
          :username => db.user,
          :password => db.password,
          :port     => db.port,
          :database => db.path[1..-1],
          :pool => 100
      )
    end

    configure do
      disable :method_override
      disable :static
      set :erb, escape_html: true
      set :slim, :pretty => true
      if(!ENV['PRODUCTION'].blank?)
        db = URI.parse(ENV['MONGO_URL'])
        use Rack::Session::Moneta, :store => Moneta.new(:Mongo,host: db.host,user: db.user,password: db.password,db:db.path[1..-1],port:db.port)
      else
        use Rack::Session::Moneta, :store => :Mongo
      end
    end

    use Rack::Deflater
    use Rack::Standards
    use Routes::Static
    unless settings.production?
      use Routes::Assets
    end

    # Other routes:
    use Routes::Nav
    use Routes::Ordering
    use Routes::API
  end
end

include Vitos::Models