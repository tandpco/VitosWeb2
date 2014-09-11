module Vitos
  module Models
    class Order < ActiveRecord::Base
      self.table_name   = 'tblOrders'
      self.primary_key  = 'OrderID'
    end
  end
end