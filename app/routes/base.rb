require 'digest/md5'
module Vitos
  module Routes
    class Base < Sinatra::Application
      configure do
        set :views, 'app/views'
        set :root, App.root

        disable :method_override
        disable :protection
        disable :static

        # set :erb, escape_html: true,
        #           layout_options: {views: 'app/views/layouts'}
        set :slim, :layout_engine => :slim, :layout => :'layouts/layout'
        set :partial_template_engine, :slim
        enable :use_code
      end

      register Extensions::Assets
      helpers Helpers
      helpers Sinatra::ContentFor

      use Warden::Manager do |manager|
        manager.default_strategies :password
        manager.failure_app = App
        manager.serialize_into_session {|user| user[:CustomerID]}
        manager.serialize_from_session {|id| Customer.find(id)}
      end
       
      Warden::Manager.before_failure do |env,opts|
        env['REQUEST_METHOD'] = 'POST'
      end

      Warden::Strategies.add(:password) do
        def valid?
          params["email"] || params["password"]
        end
     
        def authenticate!
          user = Customer.where(EMail: params["email"],Password: Digest::MD5.hexdigest(params["password"])).first
          if user
            address = user.address
            session[:addressID] = address['AddressID']
            session[:storeID] = address['StoreId']
            success!(user)
          else
            fail!("Could not log in")
          end
        end
      end
      
      def warden_handler
        env['warden']
      end
     
      def check_authentication
        unless warden_handler.authenticated?
          redirect '/login'
        end
      end
     
      def current_user
        warden_handler.user
      end
    end
  end
end