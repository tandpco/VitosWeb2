require 'digest/md5'
module Vitos
  module Routes
    class Nav < Base
      get '/' do
        slim :index
      end
      get '/login' do
        if warden_handler.authenticated?
          redirect "/order"
        end
        slim :login
      end
      get '/me' do
        # json session
        json current_user
      end
      get '/logout' do
        warden_handler.logout
        redirect "/login"
      end
      post '/login' do
        warden_handler.authenticate!
        if warden_handler.authenticated?
          redirect "/order" 
        else
          redirect "/"
        end
      end
    end
  end
end