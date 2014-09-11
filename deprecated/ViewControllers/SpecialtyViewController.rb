class SpecialtyViewController
    public

    def self.specialtyItem(data)
        unitId   = data['UnitID']
        result = Hash.new()
        result['specialty'] = nil
        result['sideGroups'] = Array.new()
        result['defaultSideGroups'] = Array.new()
        if(data['SpecialtyID'].to_s != '')
            result['specialty'] = getSpecialty(data['SpecialtyID'])
            if(data['SizeID'].to_s != '' && data['SizeID'] != 'null')
                result['sideGroups'] = getSideGroups(data['SpecialtyID'],data['StoreID'],data['UnitID'],data['SizeID'])
            end
        end
        if(data['SizeID'].to_s != '' && data['SizeID'] != 'null')
            result['defaultSideGroups'] = defaultSides(data['UnitID'],data['StoreID'],data['SizeID'])
        end
        result['extraSides']          = getSides(data['UnitID'],data['StoreID'])
        result['toppers']        = JSON.parse(TopperViewController.listToppers(data))
        result['defaults']        = JSON.parse(OrderItemViewController.getDefaultSpecialtyItems(data))
        result['sizes']          = JSON.parse(SizeViewController.listSizes(data))
        result['sauces']         = JSON.parse(SauceViewController.listSauces(data))
        result['styles']         = JSON.parse(StyleViewController.listStyles(data))
        result['allstyles']      = StyleViewController.listStylesForUnit(data)
        result['sauceModifiers'] = JSON.parse(SauceModifierViewController.listSauceModifiers(data))
        result['toppings'] = ToppingViewController.__listToppingsFromDatabase(data)

        return result.to_json
    end
    def self.getSideGroupSides(sideGroup)
        rows = ActiveRecord::Base.connection.select_all("select distinct tblSideGroup.SideGroupID, SideGroupDescription, tblSides.SideID, SideDescription, IsDefault from tblSideGroup inner join trelSideGroupSides on tblSideGroup.SideGroupID = trelSideGroupSides.SideGroupID inner join tblSides on trelSideGroupSides.SidesID = tblSides.SideID and tblSideGroup.IsActive <> 0 and tblSides.IsActive <> 0  WHERE tblSideGroup.SideGroupID = "+sideGroup+" order by tblSideGroup.SideGroupID, tblSides.SideID")
        return rows
    end
    def self.defaultSides(unitId,storeId,sizeId)
        rows = ActiveRecord::Base.connection.select_all("select SideGroupID, Quantity from trelStoreUnitSize inner join trelUnitSizeSideGroup on trelStoreUnitSize.SizeID = trelUnitSizeSideGroup.SizeID and trelStoreUnitSize.UnitID = trelUnitSizeSideGroup.UnitID where StoreID = " +storeId+ " and trelStoreUnitSize.UnitID = " +unitId+ " and trelStoreUnitSize.SizeID = " +sizeId+ " order by trelUnitSizeSideGroup.SideGroupID")

        rows.each do |row|
            row["sides"] = getSideGroupSides(row["SideGroupID"].to_s)
        end
        return rows
    end
    def self.getSides(unitId,storeId)
        rows = ActiveRecord::Base.connection.select_all("select tblSides.SideID, SideDescription, SidePrice from trelStoreSides inner join trelUnitSides on trelStoreSides.SideID = trelUnitSides.SideID and trelUnitSides.UnitID = " +unitId+ " inner join tblSides on trelUnitSides.SideID = tblSides.SideID where StoreID = " +storeId+ " and IsActive <> 0 order by tblSides.SideID")
        return rows
    end
    def self.getSpecialty(specialtyId)
        rows = ActiveRecord::Base.connection.select_all("select tblSpecialty.* from tblSpecialty where SpecialtyID = " +specialtyId)
        return rows[0]
    end
    def self.getUnit(unitId)
        rows = ActiveRecord::Base.connection.select_one("select * from tblUnit where UnitID = " +unitId)
        return rows
    end
    def self.getSideGroups(specialtyId,storeId,unitId,sizeId)
        rows = ActiveRecord::Base.connection.select_all("select SideGroupID, Quantity from trelStoreSpecialty inner join tblSpecialty on trelStoreSpecialty.SpecialtyID = tblSpecialty.SpecialtyID inner join trelSpecialtySizeSideGroup on tblSpecialty.SpecialtyID = trelSpecialtySizeSideGroup.SpecialtyID where StoreID = " +storeId+ " and trelStoreSpecialty.SpecialtyID = " +specialtyId+ " and UnitID = " +unitId+ " and SizeID = " +sizeId+ " and IsActive <> 0 order by trelSpecialtySizeSideGroup.SideGroupID")


        rows.each do |row|
            row["sides"] = getSideGroupSides(row["SideGroupID"].to_s)
        end
        return rows
    end
    def self.listSpecialties(data)
    
        unitId   = data['UnitID']
        result = Hash.new()
        result['specialties']    = listSpecialtyFromDatabase(data)
        result['toppers']        = JSON.parse(TopperViewController.listToppers(data))
        result['sizes']          = JSON.parse(SizeViewController.listSizes(data))
        result['sauces']         = JSON.parse(SauceViewController.listSauces(data))
        result['styles']         = JSON.parse(StyleViewController.listStyles(data))
        result['sauceModifiers'] = JSON.parse(SauceModifierViewController.listSauceModifiers(data))
        result['toppings']       = JSON.parse(ToppingViewController.listToppings(data))

        return result
        
    end
    
    def self.listSpecialtyFromDatabase(data)
        storeId  = data['StoreID']
        unitId   = data['UnitID']

        returnData = Array.new()

        # Create Your Own (GitHub Issue #10)
        # Pizza
        if(unitId.to_i == $PIZZA.to_i)
            unitSpecialty = $specialties["Units"].select { |t| t['UnitID'] == $PIZZA }
            if(unitSpecialty.count > 0)
                returnData.push(unitSpecialty.first['Specialties'][0])
            end
        elsif(unitId.to_i == $SUB.to_i)
            unitSpecialty = $specialties["Units"].select { |t| t['UnitID'] == $SUB }
            if(unitSpecialty.count > 0)
                returnData.push(unitSpecialty.first['Specialties'][0])
            end
        elsif(unitId.to_i == $SALAD.to_i)
            unitSpecialty = $specialties["Units"].select { |t| t['UnitID'] == $SALAD }
            if(unitSpecialty.count > 0)
                returnData.push(unitSpecialty.first['Specialties'][0])
            end
        end
        
        rows = ActiveRecord::Base.connection.select_all('SELECT [tblspecialty].* FROM [tblspecialty] inner join trelStoreSpecialty on trelStoreSpecialty.SpecialtyID = tblSpecialty.SpecialtyID where StoreID = ' + storeId + ' and UnitID = ' + unitId + ' and IsActive <> 0 and IsInternet <> 0 order by tblSpecialty.SpecialtyID')

        returnData.concat(rows)

        return returnData
    end
    
    
    # def self.getSpecialty(data)
    #     storeId  = data['StoreID']
    #     unitId   = data['UnitID']

    #     returnData = Array.new()
    #     rows = ActiveRecord::Base.connection.select_all('SELECT [tblspecialty].* FROM [tblspecialty] inner join trelStoreSpecialty on trelStoreSpecialty.SpecialtyID = tblSpecialty.SpecialtyID where StoreID = ' + storeId + ' and UnitID = ' + unitId + ' and IsActive <> 0 and IsInternet <> 0 order by tblSpecialty.SpecialtyID')

    #     returnData.concat(rows)

    #     return returnData
    # end
    
    def self.listSpecialtyFromJson(data)
        unitId   = data['UnitID'].to_s

        unitSpecialty = $specialties["Units"].select { |t| t['UnitID'] == unitId }

        returnData = Array.new()

        if(unitSpecialty.count > 0)
            returnData = unitSpecialty.first['Specialties']
        end

        return returnData

    end
end

