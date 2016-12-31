module Vitos
  module Models
    class Geoaddress < ActiveRecord::Base
      self.table_name   = 'tblCASSAddresses'
      self.primary_key  = 'GeoaddressId'
      self.belongs_to :store, foreign_key: "StoreID"
      # self.has_and_belongs_to_many :address, foreign_key: "CustomerID", association_foreign_key:"AddressID",join_table:"trelCustomerAddresses",validate:false
    end
  end
end