class SauceViewController
    public

    def self.listSauces(data)
    
        unitId   = data['UnitID']

            return listSauceFromDatabase(data)
        
    end
    
    def self.listSauceFromDatabase(data)
        storeId  = data['StoreID']
        unitId   = data['UnitID']

        rows = Array.new()
        if(unitId == "3")
            rows = ActiveRecord::Base.connection.select_all('SELECT DISTINCT [tblsauce].* FROM [tblsauce] left outer join trelUnitSauce on trelUnitSauce.SauceID = tblSauce.SauceID and ( trelUnitSauce.UnitID = ' + unitId + ' OR trelUnitSauce.UnitID = 3) and IsActive <> 0 and IsInternet <> 0 left outer join trelStoreUnitSize on trelStoreUnitSize.UnitID = trelUnitSauce.UnitID and StoreID = ' + storeId + ' AND 1 = 1')
        else
            rows = ActiveRecord::Base.connection.select_all('SELECT DISTINCT [tblsauce].* FROM [tblsauce] inner join trelUnitSauce on trelUnitSauce.SauceID = tblSauce.SauceID and trelUnitSauce.UnitID = ' + unitId + ' and IsActive <> 0 and IsInternet <> 0 inner join trelStoreUnitSize on trelStoreUnitSize.UnitID = trelUnitSauce.UnitID and StoreID = ' + storeId + ' AND 1 = 1')

        end

        return rows.to_json
    end
    
    def self.listSauceFromJson(data)
        unitId   = data['UnitID'].to_s

        unitSauce = $sauces["Units"].select { |t| t['UnitID'] == unitId }

        tblsauceJson = "[]"

        if(unitSauce.count > 0)
            tblsauceJson = unitSauce.first['Sauces'].to_json
        end

        return tblsauceJson


    end


end

