module Vitos
  module Routes
    class API < Base
      get '/api/me' do
        json current_user
      end
      get '/api/specialties' do
        rows = ActiveRecord::Base.connection.select_all('SELECT tblspecialty.* FROM tblspecialty inner join trelStoreSpecialty on trelStoreSpecialty.SpecialtyID = tblSpecialty.SpecialtyID where StoreID = ' + params[:StoreID] + ' and UnitID = ' + params[:UnitID] + ' and IsActive <> 0 and IsInternet <> 0 order by tblSpecialty.SpecialtyID').to_hash
        json rows
      end

      get '/api/item' do
          json Inventory.item(params[:StoreID], params[:UnitID], params[:SizeID], params[:SpecialtyID])
      end
      get '/api/item-sizes' do
          request.body.rewind  # in case someone already read it
          data = {"StoreID"=>params[:StoreID],"UnitID"=>params[:UnitID],"StyleID"=>params[:StyleID],"SpecialtyID"=>params[:SpecialtyID]}
          content_type :json
          StyleViewController.listSizesForStyle(data)
      end

      put '/api/order' do
          data = JSON.parse request.body.read
          content_type :json
          OrderViewController.createOrder(data,session)
      end
      get '/api/order' do
          json OrderViewController.getOrderNew({},session)
      end
      get '/api/order/lines' do
          json OrderLineViewController.getOrderLines({},session)
      end
    end
  end
end