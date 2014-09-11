class StyleViewController
    public

    def self.listStyles(data)
    
        unitId   = data['UnitID']
            return listStyleFromDatabase(data)
        
    end
    
    def self.listStyleFromDatabase(data)
        storeId  = data['StoreID']
        unitId   = data['UnitID']
        sizeId   = data['SizeID']

        rows = ActiveRecord::Base.connection.select_all('SELECT [tblstyles].* FROM [tblstyles] inner join trelSizeStyle on trelSizeStyle.StyleID = tblStyles.StyleID inner join trelUnitStyles on tblStyles.StyleID = trelUnitStyles.StyleID and trelUnitStyles.UnitID = ' + unitId + ' inner join trelStoreSizeStyle on trelStoreSizeStyle.StyleID = trelSizeStyle.StyleID and trelStoreSizeStyle.SizeID = trelSizeStyle.SizeID and trelStoreSizeStyle.StoreID = ' + storeId + ' and trelStoreSizeStyle.SizeID = ' + sizeId + ' AND 1 = 1')

        return rows.to_json
    end
    def self.listStylesForUnit(data)
        storeId  = data['StoreID']
        unitId   = data['UnitID']
        # sizeId   = data['SizeID']

        rows = ActiveRecord::Base.connection.select_all('SELECT tblstyles.StyleID,MAX(tblstyles.StyleShortDescription) as StyleShortDescription FROM [tblstyles] inner join trelSizeStyle on trelSizeStyle.StyleID = tblStyles.StyleID inner join trelUnitStyles on tblStyles.StyleID = trelUnitStyles.StyleID and trelUnitStyles.UnitID = ' + unitId + ' inner join trelStoreSizeStyle on trelStoreSizeStyle.StyleID = trelSizeStyle.StyleID and trelStoreSizeStyle.SizeID = trelSizeStyle.SizeID and trelStoreSizeStyle.StoreID = ' + storeId+' GROUP BY tblstyles.StyleID')

        return rows
    end
    
    def self.listSizesForStyle(data)
        storeId  = data['StoreID']
        unitId   = data['UnitID']
        styleId   = data['StyleID']
        # sizeId   = data['SizeID']

        rows = ActiveRecord::Base.connection.select_all('SELECT [tblsizes].*,trelStoreSizeStyle.StyleSurcharge,trelStoreUnitSize.* FROM [tblsizes] inner join trelSizeStyle on trelSizeStyle.SizeID = tblSizes.SizeID inner join trelStoreSizeStyle on trelStoreSizeStyle.SizeID = tblSizes.SizeID and trelStoreSizeStyle.StoreID = '+storeId+' and trelStoreSizeStyle.StyleID ='+styleId+' inner join trelStoreUnitSize on trelStoreUnitSize.SizeID = tblSizes.SizeID and trelStoreUnitSize.StoreID = ' + storeId + ' and trelStoreUnitSize.UnitID = ' + unitId + ' and tblSizes.IsActive <> 0 and trelSizeStyle.StyleID = '+styleId+' order by trelStoreUnitSize.SpecialtyBasePrice ASC')

        return rows.to_json
    end
    
    def self.listStyleFromJson(data)
        unitId   = data['UnitID'].to_s

        unitStyle = $styles["Units"].select { |t| t['UnitID'] == unitId }

        styleJson = "[]"

        if(unitStyle.count > 0)
            styleJson = unitStyle.first['Styles'].to_json
        end

        return styleJson

    end


end

