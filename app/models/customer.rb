module Vitos
  module Models
    class Customer < ActiveRecord::Base
      self.table_name   = 'tblCustomers'
      self.primary_key  = 'CustomerID'
      self.belongs_to :address, foreign_key: "PrimaryAddressID"
      # self.has_and_belongs_to_many :address, foreign_key: "CustomerID", association_foreign_key:"AddressID",join_table:"trelCustomerAddresses",validate:false
    end
  end
end