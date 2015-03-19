module Vitos
  module Models
    class Store < ActiveRecord::Base
      self.table_name   = 'tblStores'
      self.primary_key  = 'StoreID'

      def phone
        if !self[:Phone].blank?
          Phony.format("1#{self[:Phone].to_s}",:format => :national,:spaces => :-)[2,12]
        end
      end

    end
  end
end