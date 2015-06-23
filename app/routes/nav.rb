require 'digest/md5'
module Vitos
  module Routes
    class Nav < Base
      get '/' do
        if warden_handler.authenticated?
          redirect "/order?UnitID=1"
        else
          redirect "/login"
        end
      end
      get '/login' do
        _states = ActiveRecord::Base.connection.select_all("select MAX(State) as State FROM tblCASSAddresses GROUP BY State ORDER BY State DESC")
        _cities = ActiveRecord::Base.connection.select_all("select MAX(City) as City,MAX(State) as State FROM tblCASSAddresses GROUP BY City,State ORDER BY State DESC, City ASC")
        @cities = []
        @states = _states
        @csv_city = []
        _cities.each do |x|
          if !x["City"].blank?
            x["City"] = x["City"].strip
            @cities.push(x)
            @csv_city.push(x['City'])
          end
        end
        @csv_city = @csv_city.join(',')
        # puts('==>',@cities)
        slim :login
      end
      post '/unauthenticated' do
        redirect "/login?error=Invalid username or password."
      end
      get '/test' do
        @req = request
        slim :test
      end
      get '/locations' do
        @locations = Store.where(isActive: true)
        slim :locations
      end
      get '/deals' do

        if session[:storeID].blank?
          puts('attempt to access coupon page with no stores')
          redirect '/'
        end
        
        deals = ActiveRecord::Base.connection.select_all("select tblCoupons.CouponID, Description, tblUnit.UnitID, tblSizes.SizeID, UnitDescription, SizeDescription from tblCoupons inner join trelCouponStore on tblCoupons.CouponID = trelCouponStore.CouponID and trelCouponStore.StoreID = " +session[:storeID].to_s+ " inner join tblCouponAppliesTo on tblCoupons.CouponID = tblCouponAppliesTo.CouponID "+"inner join tblUnit on tblCouponAppliesTo.UnitID = tblUnit.UnitID "+"inner join tblSizes on tblCouponAppliesTo.SizeID = tblSizes.SizeID "+"inner join tblCouponDateRange on tblCoupons.CouponID = tblCouponDateRange.CouponID "+"where '" +Time.now.strftime("%Y-%m-%d %H:%M:%S").to_s + "' between ValidFrom and ValidTo and ValidForInternetOrder <> 0 and ShowOnWeb <> 0 order by tblSizes.SizeID ASC")
        @sizes = {}
        deals.each do |x|
          x['Dollar'] = x['Description'].scan(/\$[+-]?[0-9]{1,3}(?:,?[0-9]{3})*(?:\.[0-9]{2})?/).first
          x['Description'] = x['Description'].gsub(/\$[+-]?[0-9]{1,3}(?:,?[0-9]{3})*(?:\.[0-9]{2})?/,"").gsub(/\A[ -]+/,'')
          # x['Description']
          if !@sizes['_'+x['SizeID'].to_s].blank?
            @sizes['_'+x['SizeID'].to_s]['Content'].push(x);
          else
            @sizes['_'+x['SizeID'].to_s] = {'Content' => [x], 'SizeDescription' => x['SizeDescription'],'SizeDollar' => x['SizeDescription'].scan(/\$[+-]?[0-9]{1,3}(?:,?[0-9]{3})*(?:\.[0-9]{2})?/).first}
          end

        end
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
        if params[:email].blank?
          redirect '/login?error=please provide an email address'
          return
        end
        warden_handler.authenticate!
        if warden_handler.authenticated?
          redirect "/order?UnitID=1"
        end
      end
    end
  end
end