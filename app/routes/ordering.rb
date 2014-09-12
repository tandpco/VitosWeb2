module Vitos
  module Routes
    class Ordering < Base
      get '/order/switch-method' do
        session[:deliveryMethod] = params[:deliveryMethod].to_i
        if(!session[:orderId].blank?)
          puts('switchimgmethod '+params[:deliveryMethod])
          OrderViewController.updateDeliveryMethod(params[:deliveryMethod],session)
        end
        redirect request.referrer
      end
      get '/order' do
        check_authentication
        # @TODO: make sure database is updated to ignore subx and mac'n'cheese @database [github.com/tandpco/VitosWeb2/issues/28]
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