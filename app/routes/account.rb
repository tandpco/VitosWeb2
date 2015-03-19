module Vitos
  module Routes
    class Account < Base
      get '/account' do
        slim :account
      end
      post '/signup' do
        if(params[:components].blank?) then redirect '/?error=no address' end
        pieces =  JSON.parse(params[:components])

        # locate customer via email address
        customer = Customer.where(EMail: params[:email]).first

        # locate store from address information
        store = Hacks.getStoreByAddress(pieces)
        # if store.nil? then redirect '/login?error=invalid store' end

        address = Hacks.findOrCreateAddress(pieces,store) 
        puts(address)
        if address.nil? then redirect '/login?error=invalid address' end

        # update or insert new customer (with assigned address information)
        if customer.nil?
          customer = Customer.new
          customer[:PrimaryAddressID]   = address[:AddressID]
          customer[:FirstName]          = params[:firstname]
          customer[:LastName]           = params[:lastname]
          customer[:EMail]              = params[:email]
          customer.save()
        else
          customer[:PrimaryAddressID]   = address[:AddressID]
          customer[:FirstName]          = params[:firstname]
          customer[:LastName]           = params[:lastname]
          customer.save()
        end
        
        rel = ActiveRecord::Base.connection.select_all("select CustomerID from trelCustomerAddresses where CustomerID = #{customer[:CustomerID]} and AddressID = #{address[:AddressID]}").first
        # update relationship or create new relationship
        if rel.nil?
          ActiveRecord::Base.connection.execute("insert into trelCustomerAddresses (CustomerID, AddressID,CustomerAddressDescription) values (#{customer[:CustomerID]},#{address[:AddressID]},'')")
        end
        session[:storeID] = store[:StoreID]
        session[:addressID] = address[:AddressID]
        env['warden'].set_user(customer)
        redirect "/order?UnitID=1"
      end
      post '/update-account' do

        # locate customer via email address
        customer = current_user
          # customer[:PrimaryAddressID]   = address[:AddressID]
        customer[:FirstName]          = params[:firstname]
        customer[:LastName]           = params[:lastname]
        customer[:CellPhone]           = params[:CellPhone]
        customer[:HomePhone]           = params[:HomePhone]
        customer[:WorkPhone]           = params[:WorkPhone]
        customer.save()
        
        if(!params[:components].blank?)
          pieces =  JSON.parse(params[:components])
          # locate store from address information
          store = Hacks.getStoreByAddress(pieces)
          if store.nil? then redirect '/?error=invalid store' end

          address = Hacks.findOrCreateAddress(pieces,store) 
          if address.nil? then redirect '/?error=invalid address' end
          rel = ActiveRecord::Base.connection.select_all("select CustomerID from trelCustomerAddresses where CustomerID = #{customer[:CustomerID]} and AddressID = #{address[:AddressID]}").first
          # update relationship or create new relationship
          if rel.nil?
            ActiveRecord::Base.connection.execute("insert into trelCustomerAddresses (CustomerID, AddressID,CustomerAddressDescription) values (#{customer[:CustomerID]},#{address[:AddressID]},'')")
          end
          session[:storeID] = store[:StoreID]
          session[:addressID] = address[:AddressID]
        end
        redirect "/checkout"
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