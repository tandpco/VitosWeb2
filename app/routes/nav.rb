require 'digest/md5'
module Vitos
  module Routes
    class Nav < Base
      get '/' do
        if warden_handler.authenticated?
          redirect "/order?UnitID=1"
        end
        slim :login
      end
      get '/login' do
        redirect "/"
      end
      get '/logout' do
        warden_handler.logout
        redirect "/login"
      end
      post '/login' do
        warden_handler.authenticate!
        if warden_handler.authenticated?
          redirect "/order?UnitID=1" 
        else
          redirect "/"
        end
      end
    end
  end
end