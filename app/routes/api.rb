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
          if session[:Coupons].blank?
            json []
          else
            out = []
            used = []
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