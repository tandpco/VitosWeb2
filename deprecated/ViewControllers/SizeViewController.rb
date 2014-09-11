
class SizeViewController
    public

    def self.listSizes(data)
    
        unitId   = data['UnitID']

            return listSizeFromDatabase(data)
    
    end
    
    def self.listSizeFromDatabase(data)
        storeId  = data['StoreID']
        unitId   = data['UnitID']
        sizeId   = data['SizeID']

        rows = ActiveRecord::Base.connection.select_all('SELECT [tblsizes].* FROM [tblsizes] inner join trelStoreUnitSize on trelStoreUnitSize.SizeID = tblSizes.SizeID and trelStoreUnitSize.StoreID = ' + storeId + ' and trelStoreUnitSize.UnitID = ' + unitId + ' and tblSizes.IsActive <> 0 order by tblSizes.SizeID')

        return rows.to_json
    end
    
    def self.listSizeFromJson(data)
        unitId   = data['UnitID'].to_s

        unitSize = $sizes["Units"].select { |t| t['UnitID'] == unitId }

        sizeJson = "[]"

        if(unitSize.count > 0)
            sizeJson = unitSize.first['Sizes'].to_json
        end

        return sizeJson

    end


end

