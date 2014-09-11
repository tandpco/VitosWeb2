class TopperViewController
    public

    def self.listToppers(data)
    
        unitId   = data['UnitID']

        return listTopperFromDatabase(data)
    end
    
    def self.listTopperFromDatabase(data)
        storeId  = data['StoreID']
        unitId   = data['UnitID']

        rows = ActiveRecord::Base.connection.select_all('SELECT DISTINCT [tbltopper].* FROM [tbltopper] INNER JOIN trelUnitTopper on tblTopper.TopperID = trelUnitTopper.TopperID AND tblTopper.IsActive <> 0 INNER JOIN trelStoreUnitSize ON trelUnitTopper.UnitID = trelUnitTopper.UnitID AND trelStoreUnitSize.StoreID = ' + storeId + ' AND trelUnitTopper.UnitID = '+unitId+' AND trelStoreUnitSize.UnitID =' + unitId + ' ORDER BY tblTopper.TopperID')

        return rows.to_json
    end
    
    def self.listTopperFromJson(data)
        unitId   = data['UnitID'].to_s

        unitTopper = $toppers["Units"].select { |t| t['UnitID'] == unitId }

        topperJson = "[]"

        if(unitTopper.count > 0)
            topperJson = unitTopper.first['Toppers'].to_json
        end

        return topperJson

    end


end

