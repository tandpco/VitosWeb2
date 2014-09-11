class SauceModifierViewController
    public

    def self.listSauceModifiers(data)
    
        unitId   = data['UnitID']

            return listSauceModifierFromDatabase(data)
        
    end
    
    def self.listSauceModifierFromDatabase(data)
        storeId  = data['StoreID']
        unitId   = data['UnitID']
        sizeId   = data['SizeID']

        rows = ActiveRecord::Base.connection.select_all('SELECT [tblsaucemodifier].* FROM [tblsaucemodifier] WHERE (IsActive <> 0) ORDER BY [tblsaucemodifier].[SauceModifierID] ASC')

        return rows.to_json
    end
    
    def self.listSauceModifierFromJson(data)
        unitId   = data['UnitID'].to_s

        unitSauceModifier = $sauceModifiers["Units"].select { |t| t['UnitID'] == unitId }

        sauceModifierJson = "[]"

        if(unitSauceModifier.count > 0)
            sauceModifierJson = unitSauceModifier.first['SauceModifiers'].to_json
        end

        return sauceModifierJson

    end


end

