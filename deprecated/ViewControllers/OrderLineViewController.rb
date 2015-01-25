class OrderLineViewController
    public

    def self.getOrderLines(data,session)
        orderId   = data["OrderID"] && data["OrderID"] != "" ? data["OrderID"] : session[:orderId].to_s

        rows = ActiveRecord::Base.connection.select_all('SELECT [tblorderLines].* FROM [tblorderLines] WHERE OrderID = ' + orderId + ' AND 1 = 1 ORDER BY OrderLineID ASC')
        rows.each do |row|
            row['id'] = row["OrderLineID"]
            row['extra'] = getOrderLineData(row["OrderLineID"])
            row.keys.each do |key|
                # puts("#{key} -> #{row[key].class.to_s}, #{row[key].to_s}")
                # if(row[key].class.to_s == "String")
                    # row[key].gsub!(/'/,"\u2019")
                # end
            end
        end

        return rows
    end

    def self.getOrderSubtotal(orderId)
        return ActiveRecord::Base.connection.select_all("SELECT SUM(Cost) as Cost, SUM(Discount) as Discount FROM  tblorderLines WHERE OrderID = #{orderId}").first
    end

    def self.getSpecialty(specialtyId)
        rows = ActiveRecord::Base.connection.select_all("select tblSpecialty.* from tblSpecialty where SpecialtyID = " +specialtyId.to_s)
        return rows[0]
    end
    def self.getLineToppers(lineId)
        return !lineId ? [] :  ActiveRecord::Base.connection.select_all("select TopperHalfID,OrderLineTopperID,tblTopper.* from tblOrderLineToppers LEFT JOIN tblTopper ON tblOrderLineToppers.TopperID = tblTopper.TopperID where OrderLineID = " +lineId.to_s)
    end
    def self.getLineItems(lineId)
        return !lineId ? [] :  ActiveRecord::Base.connection.select_all("select OrderLineItemID,HalfID,tblItems.* from tblOrderLineItems LEFT JOIN tblItems ON tblOrderLineItems.ItemID = tblItems.ItemID where OrderLineID = " +lineId.to_s)
    end
    def self.getLineSides(lineId)
        return !lineId ? [] :  ActiveRecord::Base.connection.select_all("select OrderLineSideID,IsFreeSide,tblSides.* from tblOrderLineSides LEFT JOIN tblSides ON tblOrderLineSides.SideID = tblSides.SideID where OrderLineID = " +lineId.to_s)
    end
    def self.getUnit(unitId)
        rows = ActiveRecord::Base.connection.select_one("select * from tblUnit where UnitID = " +unitId.to_s)
        return rows
    end
    def self.getSize(id)
        return !id ? nil : ActiveRecord::Base.connection.select_one("select * from tblSizes where SizeID = " +id.to_s)
    end
    def self.getStyle(id)
        return !id ? nil : ActiveRecord::Base.connection.select_one("select * from tblStyles where StyleID = " +id.to_s)
    end
    def self.getSauce(id)
        return !id ? nil : ActiveRecord::Base.connection.select_one("select * from tblSauce where SauceID = " +id.to_s)
    end
    def self.getSauceModifier(id)
        return !id ? nil : ActiveRecord::Base.connection.select_one("select * from tblSauceModifier where SauceModifierID = " +id.to_s)
    end
    def self.getOrderLineData(lineId)
        ret = {}
        line = ActiveRecord::Base.connection.select_one('SELECT tblorderLines.* FROM [tblorderLines] WHERE OrderLineID = ' + lineId.to_s)
        ret[:unit]          = line['UnitID']       ? getUnit(line['UnitID'])              : nil
        ret[:specialty]     = line['SpecialtyID'] ? getSpecialty(line['SpecialtyID'])    : nil
        ret[:size]          = getSize(line['SizeID'])
        ret[:style]         = getStyle(line['StyleID'])
        ret[:sauce]         = getSauce(line['Half1SauceID'])
        ret[:sauceModifier] = getSauceModifier(line['Half1SauceModifierID'])
        ret[:toppers]       = getLineToppers(lineId)
        ret[:toppings]      = getLineItems(lineId)
        ret[:sides]         = getLineSides(lineId)
        # get order line toppers
        # get order line items
        # get order line sides
        # 
        return ret
    end
    
    def self.deleteOrderLine(orderLineId,session)
        if orderLineId.blank? then return nil end
        ActiveRecord::Base.connection.execute("DELETE FROM Tblorderlines WHERE OrderLineID = #{orderLineId}")

        orderId = session[:orderId] && session[:orderId].to_i || nil
        storeId = session[:storeID] && session[:storeID].to_i || 1
        # Update Price
        updatePrice = {
            :pOrderID => orderId,
            :pStoreID => storeId,
            :pCouponIDs => "",
            :pPromoCodes => ""
        }

        updatePriceResult = ActiveRecord::Base.connection.execute_procedure("WebRecalculateOrderPrice", updatePrice)
    end

    def self.convertToInt(value)
        if(value == 'NULL' || value.to_i == 0)
            value = nil
        else
            value = value.to_i
        end

        return value
    end

    def self.convertToFloat(value)
        if(value == 'NULL')
            value = nil
        else
            value = value.to_f
        end

        return value
    end


end

