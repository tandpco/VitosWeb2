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
      get '/order/change-store' do
        session[:storeID] = params[:StoreID].to_i
        if session[:deliveryMethod] != 2 && session[:storeID] != select_address.store[:StoreID]
          session[:deliveryMethod] = 2
        end
        if(!session[:orderId].blank?)
          if session[:storeID] != select_address.store[:StoreID]
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
        session[:deliveryMethod] = 1
        session[:completeOrder] = nil
        session[:orderId] = nil
        redirect '/order?UnitID=1'
      end
      post '/order/complete' do
        if !params[:payCash].blank?
          select_order[:PaymentTypeID] = 1
          select_order[:OrderNotes] = params[:notes]
          select_order.save()
          ActiveRecord::Base.connection.execute_procedure("WebPrintOrder", {:pStoreID => select_store[:StoreID], :pOrderID => select_order[:OrderID]})
          session[:completeOrder] = select_order[:OrderID]
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
        @req = request
        slim :checkout
      end
      get '/order' do
        check_authentication
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