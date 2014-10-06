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
      get '/locations' do
        @locations = Store.where(isActive: true)
        slim :locations
      end
      get '/deals' do
        
        @deals = ActiveRecord::Base.connection.select_all("select tblCoupons.CouponID, Description, tblUnit.UnitID, tblSizes.SizeID, UnitDescription, SizeDescription from tblCoupons inner join trelCouponStore on tblCoupons.CouponID = trelCouponStore.CouponID and trelCouponStore.StoreID = " +session[:storeID].to_s+ " inner join tblCouponAppliesTo on tblCoupons.CouponID = tblCouponAppliesTo.CouponID "+"inner join tblUnit on tblCouponAppliesTo.UnitID = tblUnit.UnitID "+"inner join tblSizes on tblCouponAppliesTo.SizeID = tblSizes.SizeID "+"inner join tblCouponDateRange on tblCoupons.CouponID = tblCouponDateRange.CouponID "+"where '" +Time.now.strftime("%Y-%m-%d %H:%M:%S").to_s + "' between ValidFrom and ValidTo and ValidForInternetOrder <> 0 and ShowOnWeb <> 0 ")
        slim :deals
      end
      get '/logout' do
        session[:completeOrder] = nil
        session[:storeID] = nil
        session[:addressID] = nil
        session[:orderId] = nil
        session[:deliveryMethod] = 1
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