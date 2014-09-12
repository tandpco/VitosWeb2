module Vitos
  module Models
    class Store < ActiveRecord::Base
      self.table_name   = 'tblStores'
      self.primary_key  = 'StoreID'
    end
  end
end