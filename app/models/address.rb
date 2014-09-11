module Vitos
  module Models
    class Address < ActiveRecord::Base
      self.table_name   = 'tblAddresses'
      self.primary_key  = 'AddressID'
      self.has_and_belongs_to_many :customer, foreign_key: "AddressID", association_foreign_key:"CustomerID",join_table:"trelCustomerAddresses",validate:false
    end
  end
end