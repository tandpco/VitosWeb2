module Vitos
  module Routes
    class API < Base
      get '/api/me' do
        json current_user
      end
      get '/api/session' do
        json session
      end
      get '/api/specialties' do
        rows = ActiveRecord::Base.connection.select_all('SELECT tblspecialty.* FROM tblspecialty inner join trelStoreSpecialty on trelStoreSpecialty.SpecialtyID = tblSpecialty.SpecialtyID where StoreID = ' + params[:StoreID] + ' and UnitID = ' + params[:UnitID] + ' and IsActive <> 0 and IsInternet <> 0 order by tblSpecialty.SpecialtyID').to_hash
        json rows
      end

      get '/api/item' do
          json Inventory.item(session[:storeID], params[:UnitID], params[:SizeID], params[:SpecialtyID])
      end
      get '/api/applied-coupons' do
          if session[:Coupons].blank? and session[:Promos].blank?
            json []
          else
            if session[:Coupons].blank?
              session[:Coupons] = []
            end
            if session[:Promos].blank?
              session[:Promos] = []
            end
            out = []
            used = []
            # coupons = []
            lines = ActiveRecord::Base.connection.select_all('SELECT [tblorderLines].* FROM [tblorderLines] WHERE OrderID = ' + session[:orderId].to_s + ' AND 1 = 1 ORDER BY OrderLineID ASC')
            lines.each do |line|
              if !line['CouponID'].blank?
                used.push(line['CouponID'])
              end
            end
            session[:Coupons].each do |x|
              item = ActiveRecord::Base.connection.select_all('SELECT * FROM tblCoupons WHERE CouponID = '+x.to_s).first.to_hash
              if used.include? x
                item[:Used] = true
              else
                item[:Used] = false
              end
              # coupons.push(item['CouponID'])
              out.push(item)
            end
            session[:Promos].each do |x|
              item = ActiveRecord::Base.connection.select_all('SELECT tblCoupons.*,PromoCode FROM tblCouponsPromoCodes inner join tblCoupons on tblCouponsPromoCodes.CouponID = tblCoupons.CouponID  WHERE PromoCode = \''+x.to_s+'\'').first.to_hash
              if session[:Coupons].include? item['CouponID']
                next
              end
              if used.include? item['CouponID']
                item[:Used] = true
              else
                item[:Used] = false
              end
              out.push(item)
            end
            json out
          end
      end
      get '/api/item-sizes' do
        puts(session[:storeID])
          json Inventory.listSizesForStyle(session[:storeID],params[:UnitID],params[:StyleID])
      end

      put '/api/order' do
          data = JSON.parse request.body.read
          content_type :json
          OrderViewController.createOrder(data,session,current_user)
      end
      get '/api/order' do
          if(session[:orderId].blank?)
            json nil
          else
            json OrderViewController.getOrderNew({},session)
          end
      end
      post '/api/order/update-tip' do
          data = JSON.parse request.body.read
          # if(session[:orderId].blank?) then return nil end
          if(session[:orderId].blank?)
            json nil
          else
            select_order[:Tip] = data['tip'].blank? ? 0 : data['tip']
            select_order.save()
            json true
          end
      end
      post '/api/order/add-promo' do
        data = JSON.parse request.body.read
        if session[:Promos].blank?
          session[:Promos] = [data['CouponCode'].to_s]
        else
          session[:Promos].push(data['CouponCode'].to_s)
        end
        OrderViewController.updatePrice(session);
        json session[:Promos]
        # redirect "/order?UnitID=1"
      end
      get '/api/order/lines' do
          # if(session[:orderId].blank?) then return nil end
          if(session[:orderId].blank?)
            json nil
          else
            json OrderLineViewController.getOrderLines({},session)
          end
      end
      delete '/api/order/lines/:id' do |lineId|
          json OrderLineViewController.deleteOrderLine(lineId,session)
      end
    end
  end
end