class ToppingViewController
    public

    def self.listToppings(data)
    
        unitId   = data['UnitID']


            return listToppingsFromDatabase(data)
    
    end
    
    def self.listToppingsFromDatabase(data)
        storeId  = data['StoreID']
        unitId   = data['UnitID']

        rows = ActiveRecord::Base.connection.select_all('SELECT [tblitems].* FROM [tblitems] inner join trelStoreItem on trelStoreItem.ItemID = tblItems.ItemID inner join trelUnitItems on tblItems.ItemID = trelUnitItems.ItemID inner join tblUnit on trelUnitItems.UnitID = tblUnit.UnitID where StoreID = ' + storeId + ' and trelUnitItems.UnitID = ' + unitId + ' and tblItems.IsActive <> 0 and tblItems.IsInternet <> 0 AND 1 = 1 order by ItemDescription')

        rows.each do |row|
            row.keys.each do |key|
                if(row[key].class.to_s == "String")
                    row[key].gsub!(/'/,"\u2019")
                end
            end
        end

        return rows.to_json
    end
    def self.__listToppingsFromDatabase(data)
        storeId  = data['StoreID']
        unitId   = data['UnitID']

        rows = ActiveRecord::Base.connection.select_all("select tblItems.ItemID, ItemDescription, ItemCount, FreeItemFlag, AllowHalfItems,isCheese,IsBaseCheese from trelStoreItem inner join tblItems on trelStoreItem.ItemID = tblItems.ItemID inner join trelUnitItems on tblItems.ItemID = trelUnitItems.ItemID inner join tblUnit on trelUnitItems.UnitID = tblUnit.UnitID where StoreID = " +storeId+ " and trelUnitItems.UnitID = " +unitId+ " and tblItems.IsActive <> 0 and tblItems.IsInternet <> 0 order by ItemDescription")

        rows.each do |row|
            row.keys.each do |key|
                if(row[key].class.to_s == "String")
                    row[key].gsub!(/'/,"\u2019")
                end
            end
        end

        return rows
    end
    
    def self.listToppingsFromJson(data)
        unitId   = data['UnitID'].to_s

        unitItems = $items["Units"].select { |s| s['UnitID'] == unitId }

        tblitemsJson = "[]"

        if(unitItems.count > 0)
            tblitemsJson = unitItems.first['Items'].to_json
        end

        return tblitemsJson


    end


end

