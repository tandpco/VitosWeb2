module Vitos
  module Routes
    class Ordering < Base
      get '/order/switch-method' do
        session[:deliveryMethod] = params[:deliveryMethod].to_i
        if session[:deliveryMethod] == 1
          session[:storeID] = select_address.store[:StoreID]
        end
        if(!session[:orderId].blank?)
          # select_order[:StoreID] = session[:storeID]
          # select_order[:OrderTypeID] = session[:deliveryMethod]
          # select_order.save()
          # puts('switchimgmethod '+params[:deliveryMethod])
          OrderViewController.updateDeliveryMethod(params[:deliveryMethod],session)
        end
        if session[:deliveryMethod] == 1
          redirect request.referrer
        else
          redirect "/locations"
        end
      end
      get '/order/notify' do
        @lines = OrderLineViewController.getOrderLines({},session)
        @order = OrderViewController.getOrderNew({},session)
        options = {
          # :to => current_user[:EMail].blank? && 'me@david.gs' || current_user[:EMail],
          # :to => 'me@david.gs',
          :to => current_user[:EMail].blank? && 'me@david.gs' || current_user[:EMail],
          :from => 'ordering@vitos.com',
          :subject => "Vito's Pizza Order #{@order['OrderID']} Confirmation",
          # :body => '',
          :html_body => (slim :notify, :layout=>false),
          :via => :smtp,
          :via_options => {
            :address => 'smtp.sendgrid.net',
            :port => 2525,
            :enable_starttls_auto => true,
            :user_name => 'dboskovic',
            :password => '900miles',
            :authentication => :plain,
            :domain => 'localhost.localdomain'
          }
        }

        puts(Pony.mail(options))
        slim :notify, :layout => false
      end
      get '/order/preload-coupon' do
        if session[:Coupons].blank?
          session[:Coupons] = [params[:CouponID].to_i]
        else
          session[:Coupons].push(params[:CouponID].to_i)
        end
        # OrderViewController.updatePrice(session);
        redirect "/"
      end
      get '/order/apply-coupon' do
        if session[:Coupons].blank?
          session[:Coupons] = [params[:CouponID].to_i]
        else
          session[:Coupons].push(params[:CouponID].to_i)
        end
        OrderViewController.updatePrice(session);
        redirect "/order?UnitID=1"
      end
      post '/order/pay-return' do

        select_order[:PaymentTypeID] = 3
        select_order[:PaymentAuthorization] = params[:ReferenceNumber]
        select_order[:PaymentEmpID] = 1
        select_order[:IsPaid] = 1
        select_order.save()
        ActiveRecord::Base.connection.execute("UPDATE tblOrders SET PaidDate = GetDate() WHERE OrderID = #{select_order[:OrderID]}")

        ActiveRecord::Base.connection.execute_procedure("WebPrintOrder", {:pStoreID => select_store[:StoreID], :pOrderID => select_order[:OrderID]})
        session[:completeOrder] = select_order[:OrderID]
        session[:orderId] = nil
        # json params.to_hash
        redirect '/order/thanks'
      end
      post '/order/securesubmit-complete' do

        auth_amount = Hacks.totalOrder(select_order)
        # token_value
        Hps.configure do |config|
          config.secret_api_key = select_store['SSAPISK']
        end  
        charge_service = Hps::HpsChargeService.new
        trans_details = Hps::HpsTransactionDetails.new
        trans_details.customer_id = current_user[:CustomerID]
        trans_details.invoice_number = select_order[:OrderID]
        trans_details.memo = 'Vitos 2.0'
        auth_response = charge_service.authorize(auth_amount, "usd", params[:token_value],nil,false,trans_details)
        puts auth_response
        if auth_response.response_text != 'APPROVAL'
          return "Card was not approved."
        end

        # puts 'happy'
        # puts params
        # json auth_response
        # return
        # sSQL = "update tblOrders set PaidDate = GetDate(), IsPaid = 1, PaymentTypeID = 3, PaymentEmpID = 1, Tip = " & pdTip & ", PaymentAuthorization = '" & psReference & "' where OrderID = " & pnOrderID
        select_order[:PaymentTypeID] = 3
        select_order[:SSTransactionID] = auth_response.transaction_id
        select_order[:PaymentAuthorization] = auth_response.authorization_code
        select_order[:PaymentEmpID] = 1
        select_order[:IsPaid] = 1
        select_order[:StoreID] = select_store[:StoreID]
        if !select_address.nil?
          select_order[:AddressID] = select_address[:AddressID]
        end
        select_order.save()
        ActiveRecord::Base.connection.execute("UPDATE tblOrders SET PaidDate = GetDate() WHERE OrderID = #{select_order[:OrderID]}")

        ActiveRecord::Base.connection.execute_procedure("WebPrintOrder", {:pStoreID => select_store[:StoreID], :pOrderID => select_order[:OrderID]})
        session[:completeOrder] = select_order[:OrderID]


        @lines = OrderLineViewController.getOrderLines({},session)
        @order = OrderViewController.getOrderNew({},session)
        options = {
          # :to => 'me@david.gs',
          :to => current_user[:EMail].blank? && 'me@david.gs' || current_user[:EMail],
          :from => 'Vitos <ordering@vitos.com>',
          :subject => "Vito's Pizza Order #{@order['OrderID']} Confirmation",
          :html_body => (slim :notify, :layout=>false),
          :via => :smtp,
          :via_options => {
            # :openssl_verify_mode => OpenSSL::SSL::VERIFY_NONE,
            :address => 'smtp.sendgrid.net',
            :port => 2525,
            :enable_starttls_auto => true,
            :user_name => 'dboskovic',
            :password => '900miles',
            :authentication => :plain,
            :domain => 'localhost.localdomain'
          }
        }

        Pony.mail(options)

        session[:orderId] = nil
        # json params.to_hash
        redirect '/order/thanks'
      end

      get '/order/change-store' do
        session[:storeID] = params[:StoreID].to_i
        if select_address.nil? || session[:deliveryMethod] != 2 && session[:storeID] != select_address.store[:StoreID]
          session[:deliveryMethod] = 2
        end
        if(!session[:orderId].blank?)
          if select_address.nil? || session[:storeID] != select_address.store[:StoreID]
            OrderViewController.updateDeliveryMethod(2,session)
          else
            select_order[:StoreID] = session[:storeID]
            select_order.save()
            # puts('switchimgmethod '+params[:deliveryMethod])
            OrderViewController.updateDeliveryMethod(params[:deliveryMethod],session)
          end
        end
        redirect request.referrer
      end
      get '/order/create-new' do
        session[:deliveryMethod] = select_address.blank? && 2 || 1
        session[:completeOrder] = nil
        session[:orderId] = nil
        if !select_address.blank?
          session[:storeID] = select_address.store[:StoreID]
        end
        redirect '/order?UnitID=1'
      end
      get '/checkout/card' do
        slim :card
      end
      post '/order/complete' do
        if !params[:payCash].blank?
          select_order[:PaymentTypeID] = 1
          select_order[:StoreID] = select_store[:StoreID]
          if !select_address.nil?
            select_order[:AddressID] = select_address[:AddressID]
          end
          select_order[:OrderNotes] = params[:notes]
          select_order.save()
          ActiveRecord::Base.connection.execute_procedure("WebPrintOrder", {:pStoreID => select_store[:StoreID], :pOrderID => select_order[:OrderID]})
          session[:completeOrder] = select_order[:OrderID]


          @lines = OrderLineViewController.getOrderLines({},session)
          @order = OrderViewController.getOrderNew({},session)
          options = {
            # :to => 'me@david.gs',
            :to => current_user[:EMail].blank? && 'me@david.gs' || current_user[:EMail],
            :from => 'Vitos <ordering@vitos.com>',
            :subject => "Vito's Pizza Order #{@order['OrderID']} Confirmation",
            :html_body => (slim :notify, :layout=>false),
            :via => :smtp,
            :via_options => {
              # :openssl_verify_mode => OpenSSL::SSL::VERIFY_NONE,
              :address => 'smtp.sendgrid.net',
              :port => 2525,
              :enable_starttls_auto => true,
              :user_name => 'dboskovic',
              :password => '900miles',
              :authentication => :plain,
              :domain => 'localhost.localdomain'
            }
          }

          Pony.mail(options)


          session[:orderId] = nil
          redirect '/order/thanks'
        else
          select_order[:PaymentTypeID] = 3
          select_order[:OrderNotes] = params[:notes]
          select_order.save()
          redirect 'https://hps.webportal.test.secureexchange.net/PaymentMain.aspx', 307
        end
      end
      get '/order/thanks' do
        if session[:completeOrder].blank?
          redirect '/checkout'
        end
        slim :thanks
      end
      get '/checkout' do
        if !select_order
          redirect '/order?UnitID=1'
        end
        @req = request
        slim :checkout
      end
      get '/order' do
        check_authentication
        if session[:storeID].blank?
          redirect '/locations?no_location=true'
        else
          if(params[:UnitID].blank?)
            @units = ActiveRecord::Base.connection.select_all("SELECT tblUnit.* FROM tblUnit WHERE UnitID NOT IN (1,3,14,32) and UnitID NOT IN (17,21,18,28) and IsActive <> 0 and IsInternet <> 0 order by UnitMenuSortOrder")
          else
            @units = ActiveRecord::Base.connection.select_all("SELECT tblUnit.* FROM tblUnit WHERE UnitID = #{params[:UnitID]} and UnitID NOT IN (17,21,18,28) and IsActive <> 0 and IsInternet <> 0 order by UnitMenuSortOrder")
          end
          @units.each do |unit|
            unit[:photo] = '/img/'+Hacks.specialtyImages(nil,unit['UnitID'])
            unit[:items] = ActiveRecord::Base.connection.select_all("SELECT tblspecialty.* FROM tblspecialty inner join trelStoreSpecialty on trelStoreSpecialty.SpecialtyID = tblSpecialty.SpecialtyID where StoreID = #{session[:storeID]} and UnitID = #{unit['UnitID']} and IsActive <> 0 and IsInternet <> 0 order by tblSpecialty.SpecialtyID")
            unit[:items].each do |item|
              # puts(item['SpecialtyID'],Hacks.specialtyImages(item['SpecialtyID']))
              item[:photo] = '/img/'+Hacks.specialtyImages(item['SpecialtyID'],nil)
            end
          end
          # json @units
          slim :order
        end
      end
    end
  end
end