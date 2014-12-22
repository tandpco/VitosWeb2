class Inventory
    public
    def self.item(storeID, unitID, sizeID = nil, specialtyID = nil)

        result = {}
        result[:defaultSideGroups]  = []
        result[:sideGroups]         = sideGroups(storeID,unitID,sizeID,specialtyID)
        result[:specialty]          = specialty(specialtyID)
        result[:extraSides]         = extraSides(storeID,unitID)
        result[:toppers]            = toppers(storeID,unitID)
        result[:specialtyDefaults]  = specialtyDefaults(storeID,unitID,specialtyID)
        result[:sizes]              = sizes(storeID,unitID,sizeID)
        result[:sauces]             = sauces(storeID,unitID)
        result[:styles]             = styles(storeID,unitID)
        result[:sauceModifiers]     = sauceModifiers()
        result[:toppings]           = toppings(storeID,unitID)
        result[:defaultSideGroups]  = defaultSideGroups(storeID,unitID,sizeID || result[:sizes][0]['SizeID'])
        return result
    end

    def self.listSizesForStyle(storeID,unitID,styleID)
        return ActiveRecord::Base.connection.select_all("SELECT [tblsizes].*,trelStoreSizeStyle.StyleSurcharge,trelStoreUnitSize.* FROM [tblsizes] inner join trelSizeStyle on trelSizeStyle.SizeID = tblSizes.SizeID inner join trelStoreSizeStyle on trelStoreSizeStyle.SizeID = tblSizes.SizeID and trelStoreSizeStyle.StoreID = #{storeID} and trelStoreSizeStyle.StyleID =#{styleID} inner join trelStoreUnitSize on trelStoreUnitSize.SizeID = tblSizes.SizeID and trelStoreUnitSize.StoreID = #{storeID} and trelStoreUnitSize.UnitID = #{unitID} and tblSizes.IsActive <> 0 and trelSizeStyle.StyleID = #{styleID} order by trelStoreUnitSize.SpecialtyBasePrice ASC")
    end
    def self.toppings(storeID,unitID)
        return ActiveRecord::Base.connection.select_all("select tblItems.ItemID, ItemDescription, ItemCount, FreeItemFlag, AllowHalfItems,isCheese,IsBaseCheese from trelStoreItem inner join tblItems on trelStoreItem.ItemID = tblItems.ItemID inner join trelUnitItems on tblItems.ItemID = trelUnitItems.ItemID inner join tblUnit on trelUnitItems.UnitID = tblUnit.UnitID where StoreID = #{storeID} and trelUnitItems.UnitID = #{unitID} and tblItems.IsActive <> 0 and tblItems.IsInternet <> 0 order by ItemDescription")
    end
    def self.sauceModifiers
        return ActiveRecord::Base.connection.select_all("SELECT [tblsaucemodifier].* FROM [tblsaucemodifier] WHERE (IsActive <> 0) ORDER BY [tblsaucemodifier].[SauceModifierID] ASC")
    end
    
    def self.styles(storeID,unitID)
        return ActiveRecord::Base.connection.select_all("SELECT tblstyles.StyleID,MAX(tblstyles.StyleShortDescription) as StyleShortDescription FROM [tblstyles] inner join trelSizeStyle on trelSizeStyle.StyleID = tblStyles.StyleID inner join trelUnitStyles on tblStyles.StyleID = trelUnitStyles.StyleID and trelUnitStyles.UnitID = #{unitID} inner join trelStoreSizeStyle on trelStoreSizeStyle.StyleID = trelSizeStyle.StyleID and trelStoreSizeStyle.SizeID = trelSizeStyle.SizeID and trelStoreSizeStyle.StoreID = #{storeID} GROUP BY tblstyles.StyleID")
    end
    def self.sauces(storeID,unitID)
        return ActiveRecord::Base.connection.select_all("SELECT DISTINCT [tblsauce].* FROM [tblsauce] inner join trelUnitSauce on trelUnitSauce.SauceID = tblSauce.SauceID and trelUnitSauce.UnitID = #{unitID} and IsActive <> 0 and IsInternet <> 0 inner join trelStoreUnitSize on trelStoreUnitSize.UnitID = trelUnitSauce.UnitID and StoreID = #{storeID}")

    end
    def self.sizes(storeID,unitID,sizeID)
        if(!sizeID.blank?) then return nil end
        return ActiveRecord::Base.connection.select_all("SELECT [tblsizes].*,trelStoreUnitSize.* FROM [tblsizes] inner join trelStoreUnitSize on trelStoreUnitSize.SizeID = tblSizes.SizeID and trelStoreUnitSize.StoreID = #{storeID} and trelStoreUnitSize.UnitID = #{unitID} and tblSizes.IsActive <> 0 order by trelStoreUnitSize.SpecialtyBasePrice ASC")
    end
    
    def self.specialtyDefaults(storeID,unitID,specialtyID)
        if(specialtyID.blank?) then return nil end
        return ActiveRecord::Base.connection.select_all("select tblItems.ItemID, ItemDescription, ItemCount, FreeItemFlag, SpecialtyItemQuantity from trelStoreSpecialty inner join tblSpecialty on trelStoreSpecialty.SpecialtyID = tblSpecialty.SpecialtyID inner join trelSpecialtyItem on tblSpecialty.SpecialtyID = trelSpecialtyItem.SpecialtyID inner join tblItems on trelSpecialtyItem.ItemID = tblItems.ItemID inner join trelStoreItem on trelStoreSpecialty.StoreID = trelStoreItem.StoreID and tblItems.ItemID = trelStoreItem.ItemID inner join trelUnitItems on tblSpecialty.UnitID = trelUnitItems.UnitID and tblItems.ItemID = trelUnitItems.ItemID where trelStoreSpecialty.StoreID = #{storeID} and tblSpecialty.UnitID = #{unitID} and trelStoreSpecialty.SpecialtyID = #{specialtyID} and tblItems.IsActive <> 0 order by ItemDescription")
    end

    def self.toppers(storeID,unitID)
        return ActiveRecord::Base.connection.select_all("SELECT DISTINCT [tbltopper].* FROM [tbltopper] INNER JOIN trelUnitTopper on tblTopper.TopperID = trelUnitTopper.TopperID AND tblTopper.IsActive <> 0 INNER JOIN trelStoreUnitSize ON trelUnitTopper.UnitID = trelUnitTopper.UnitID AND trelStoreUnitSize.StoreID = #{storeID} AND trelUnitTopper.UnitID = #{unitID} AND trelStoreUnitSize.UnitID =#{unitID} ORDER BY tblTopper.TopperID")
    end
    def self.defaultSideGroups(storeID,unitID,sizeID=nil)
        if(sizeID.blank?) then return [] end
        # rows = ActiveRecord::Base.connection.select_all("select distinct tblSideGroup.SideGroupID, SideGroupDescription, tblSides.SideID, SideDescription, IsDefault from tblSideGroup inner join trelSideGroupSides on tblSideGroup.SideGroupID = trelSideGroupSides.SideGroupID inner join tblSides on trelSideGroupSides.SidesID = tblSides.SideID and tblSideGroup.IsActive <> 0 and tblSides.IsActive <> 0 order by tblSideGroup.SideGroupID, tblSides.SideID")
        rows = ActiveRecord::Base.connection.select_all("select SideGroupID, Quantity from trelStoreUnitSize inner join trelUnitSizeSideGroup on trelStoreUnitSize.SizeID = trelUnitSizeSideGroup.SizeID and trelStoreUnitSize.UnitID = trelUnitSizeSideGroup.UnitID where StoreID = #{storeID} and trelStoreUnitSize.UnitID = #{unitID} and trelStoreUnitSize.SizeID = #{sizeID} order by trelUnitSizeSideGroup.SideGroupID")

        rows.each do |row|
            row[:sides] = __getSideGroupSides(row["SideGroupID"].to_s)
        end
        return rows
    end
    def self.extraSides(storeID,unitID)
        return ActiveRecord::Base.connection.select_all("select tblSides.SideID, SideDescription, SidePrice from trelStoreSides inner join trelUnitSides on trelStoreSides.SideID = trelUnitSides.SideID and trelUnitSides.UnitID = #{unitID} inner join tblSides on trelUnitSides.SideID = tblSides.SideID where StoreID = #{storeID} and IsActive <> 0 order by tblSides.SideID")
    end
    def self.specialty(specialtyID)
        if(specialtyID.blank?) then return nil end
        return ActiveRecord::Base.connection.select_all("select tblSpecialty.* from tblSpecialty where SpecialtyID = #{specialtyID}").first
    end
    def self.sideGroups(storeID, unitID, sizeID = nil, specialtyID = nil)
        if(sizeID.blank? || specialtyID.blank?) then return [] end
        return ActiveRecord::Base.connection.select_all("select SideGroupID, Quantity from trelStoreSpecialty inner join tblSpecialty on trelStoreSpecialty.SpecialtyID = tblSpecialty.SpecialtyID inner join trelSpecialtySizeSideGroup on tblSpecialty.SpecialtyID = trelSpecialtySizeSideGroup.SpecialtyID where StoreID = #{storeID} and trelStoreSpecialty.SpecialtyID = #{specialtyID} and UnitID = #{unitID} and SizeID = #{sizeID} and IsActive <> 0 order by trelSpecialtySizeSideGroup.SideGroupID").to_hash


        rows.each do |row|
            row["sides"] = getSideGroupSides(row["SideGroupID"].to_s)
        end
        return rows
    end
    def self.__getSideGroupSides(sideGroup)
        return ActiveRecord::Base.connection.select_all("select distinct tblSideGroup.SideGroupID, SideGroupDescription, tblSides.SideID, SideDescription, IsDefault from tblSideGroup inner join trelSideGroupSides on tblSideGroup.SideGroupID = trelSideGroupSides.SideGroupID inner join tblSides on trelSideGroupSides.SidesID = tblSides.SideID and tblSideGroup.IsActive <> 0 and tblSides.IsActive <> 0  WHERE tblSideGroup.SideGroupID = #{sideGroup} and tblSides.SideID != 46 order by tblSideGroup.SideGroupID, tblSides.SideID")
    end
end

