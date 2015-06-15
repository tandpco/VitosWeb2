require 'digest/md5'
module Vitos
  module Routes
    class Test < Base
      post '/test-signup' do
        if(params[:components].blank?) then redirect '/login?r_error=no address' end
        pieces =  JSON.parse(params[:components])

        if params[:email].blank?
          redirect '/login?r_error=please provide an email address'
          return
        end

        # locate customer via email address
        customer = Customer.where(EMail: params[:email]).first

        # locate store from address information
        store = Hacks.getStoreByAddress(pieces)
        # if store.nil? then redirect '/login?r_error=invalid store' end
        if !store.nil?
          address = Hacks.findOrCreateAddress(pieces,store)
          if address.nil? then redirect '/login?r_error=invalid address' end
        end

        # update or insert new customer (with assigned address information)
        if customer.nil?
          customer = Customer.new
          if !address.nil?
            customer[:PrimaryAddressID]   = address[:AddressID]
          end
          customer[:FirstName]          = params[:firstname]
          customer[:LastName]           = params[:lastname]
          customer[:EMail]              = params[:email]
          customer.save()
        else
          # customer[:PrimaryAddressID]   = address[:AddressID]
          if !address.nil?
            customer[:PrimaryAddressID]   = address[:AddressID]
          end
          customer[:FirstName]          = params[:firstname]
          customer[:LastName]           = params[:lastname]
          customer.save()
        end
        # json customer
        if !address.nil?
          rel = ActiveRecord::Base.connection.select_all("select CustomerID from trelCustomerAddresses where CustomerID = #{customer[:CustomerID]} and AddressID = #{address[:AddressID]}").first
          # update relationship or create new relationship
          if rel.nil?
            ActiveRecord::Base.connection.execute("insert into trelCustomerAddresses (CustomerID, AddressID,CustomerAddressDescription) values (#{customer[:CustomerID]},#{address[:AddressID]},'')")
          end
        end
        if !store.nil? then session[:storeID] = store[:StoreID] end
        if !address.nil? then session[:addressID] = address[:AddressID] end
        env['warden'].set_user(customer)
        redirect "/order?UnitID=1"
      end
      get '/test-pay' do
        slim :testpay
      end
      post '/test-pay-return' do
        json params.to_hash
      end
    end
  end
end