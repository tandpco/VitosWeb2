class OrderItemViewController
    public


    def self.getDefaultSpecialtyItems(data)
        storeId     = data['StoreID'].to_s
        unitId      = data['UnitID'].to_s
        specialtyId = data['SpecialtyID'].to_s

        rows = ActiveRecord::Base.connection.select_all('select tblItems.ItemID, ItemDescription, ItemCount, FreeItemFlag, SpecialtyItemQuantity from trelStoreSpecialty inner join tblSpecialty on trelStoreSpecialty.SpecialtyID = tblSpecialty.SpecialtyID inner join trelSpecialtyItem on tblSpecialty.SpecialtyID = trelSpecialtyItem.SpecialtyID inner join tblItems on trelSpecialtyItem.ItemID = tblItems.ItemID inner join trelStoreItem on trelStoreSpecialty.StoreID = trelStoreItem.StoreID and tblItems.ItemID = trelStoreItem.ItemID inner join trelUnitItems on tblSpecialty.UnitID = trelUnitItems.UnitID and tblItems.ItemID = trelUnitItems.ItemID where trelStoreSpecialty.StoreID = ' + storeId + ' and tblSpecialty.UnitID = ' + unitId + ' and trelStoreSpecialty.SpecialtyID = ' + specialtyId + ' and tblItems.IsActive <> 0 order by ItemDescription')

        return rows.to_json
    end

end

