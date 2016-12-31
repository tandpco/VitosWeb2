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

      # register Extensions::Assets
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
            # @NOTE: Possibly verify the user for an address on login if there's none linked.
            session[:addressID] = address['AddressID']
            session[:storeID] = address['StoreID']
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
          redirect '/login?error=1'
        end
      end

      def select_store
        if !@store.nil?
          return @store
        end
        if !session[:storeID].blank?
          @store = Store.find(session[:storeID])
          return @store
        end
        return nil
      end
      def is_closed
        if !select_store.nil?
          return Hacks.storeIsClosed(select_store)
        end
        return nil
      end
      def delivery_method_selected
        session[:delivery_method_selected].present?
      end
      def confirmed_location
        session[:confirmed_location].present?
      end
      def render_location_confirmation?
        !confirmed_location && session[:deliveryMethod] == 2 && request.path_info != '/locations'
      end
      def month_names
        return Date::MONTHNAMES.slice(1,12)
      end

      def select_address
        if !@address.nil?
          return @address
        end
        if !session[:addressID].blank?
          @address = Address.find(session[:addressID])
          return @address
        end
        return nil
      end
     
      def select_order
        if !@order.nil?
          return @order
        end
        if !session[:orderId].blank?
          @order = Order.find(session[:orderId])
          return @order
        end
        return nil
      end
     
      def current_user
        warden_handler.user
      end
    end
  end
end