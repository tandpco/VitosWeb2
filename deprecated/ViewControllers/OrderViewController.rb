require 'time'
class OrderViewController
    public
    def self.getOrder(data,session)
        orderId = session[:orderId]
        if !orderId
            return nil
        end

        rows = ActiveRecord::Base.connection.select_all('SELECT [tblorders].* FROM [tblorders] WHERE OrderID = ' + orderId)

        rows.each do |row|
            row.keys.each do |key|
                # puts("#{key} -> #{row[key].class.to_s}, #{row[key].to_s}")
                # if(row[key].class.to_s == "String")
                    # row[key].gsub!(/'/,"\u2019")
                # end
            end
        end

        return rows.to_json
    end
    def self.getOrderNew(data,session)
        orderId = session[:orderId].to_s
        if !orderId
            return nil
        end

        row = ActiveRecord::Base.connection.select_one('SELECT tblorders.* FROM tblorders WHERE OrderID = ' + orderId)
        return row
    end
    def self.updateDeliveryMethod(method,session)
        orderId = session[:orderId] && session[:orderId].to_i || nil
        storeId = session[:storeID] && session[:storeID].to_i || 1
        theStore = Store.find(storeId)
        if(orderId.blank?) then return nil end
        if(method.to_i == 2)
            ActiveRecord::Base.connection.execute("UPDATE tblOrders SET OrderTypeID = 2,DeliveryCharge=0,DriverMoney=0 WHERE OrderID = #{orderId}")
        else
            ActiveRecord::Base.connection.execute("UPDATE tblOrders SET OrderTypeID = 1,DeliveryCharge=#{theStore['DefaultDeliveryCharge']},DriverMoney=#{theStore['DefaultDriverMoney']} WHERE OrderID = #{orderId}")
        end

        # Update Price
        updatePrice = {
            :pOrderID => orderId,
            :pStoreID => storeId,
            :pCouponIDs => session[:Coupons].blank? ? "" : session[:Coupons].join(','),
            :pPromoCodes => session[:Promos].blank? ? "" : session[:Promos].join(',')
        }

        ActiveRecord::Base.connection.execute_procedure("WebRecalculateOrderPrice", updatePrice)
    end
    def self.createOrder(data,session,current_user)
        result = Hash.new()
        # Order
        order = data['order']
        orderItem = data['orderItem']
        orderId = session[:orderId] && session[:orderId].to_i || nil
        storeId = session[:storeID] && session[:storeID].to_i || 7
        orderTypeID = session[:deliveryMethod].blank? && 1 || session[:deliveryMethod].to_i
        session[:deliveryMethod] = orderTypeID

        theStore = Store.find(storeId)

        # puts("OrderID: " + orderId.to_s)
        address = current_user.address
        if(orderId == nil || orderId < 1)

            newOrder = Hash.new()

            newOrder['pSessionID']       = 0
            newOrder['pIPAddress']       = "127.0.0.1" #@TODO: connect this to request.ip
            newOrder['pEmpID']           = 1
            newOrder['pRefID']           = nil
            dnow = Time.now.getlocal('-05:00')
            if dnow.hour < 5
                odnow = Time.now.getlocal('-10:00')
                newOrder['pTransactionDate'] = odnow.strftime('%F')
            else
                newOrder['pTransactionDate'] = dnow.strftime('%F')
            end
            newOrder['pStoreID']         = storeId

            # get from session
            newOrder['pCustomerID']      = current_user['CustomerID']

            newOrder['pCustomerName']    = current_user['FirstName']+' '+current_user['LastName']
            newOrder['pCustomerPhone']   = current_user['HomePhone'] || current_user['CellPhone'] || current_user['WorkPhone']
            newOrder['pAddressID']       = address['AddressID']
            newOrder['pOrderTypeID']     = convertToInt(orderTypeID)

            # auto determine this
            if orderTypeID != 2
                newOrder['pDeliveryCharge']  = theStore['DefaultDeliveryCharge']
                newOrder['pDriverMoney']     = theStore['DefaultDriverMoney']
            else
                newOrder['pDeliveryCharge']  = 0
                newOrder['pDriverMoney']     = 0
            end
            newOrder['pOrderNotes']      = order['pOrderNotes']
            
            orderResult = ActiveRecord::Base.connection.execute_procedure("AddOrder", newOrder)
            orderId = convertToInt(orderResult[0]['newid'])
            session[:orderId] = orderId
            # SessionViewController.set("orderId",orderId,session)
        end
        qtyLimit = orderItem['pQuantity'].blank? && 1 || convertToInt(orderItem['pQuantity'])
        qtyPointer = 1
        while qtyPointer <= qtyLimit
            # puts("==> adding to to order #{qtyPointer} of #{qtyLimit}")
            orderItem['pOrderID']     = orderId

            # OrderItem

            # Handle side deals
            itemUnitId      = convertToInt(orderItem['pUnitID'])
            itemSpecialtyId = convertToInt(orderItem['pSpecialtyID'])

            half1SauceID         = convertToInt(orderItem['pHalf1SauceID'])
            half2SauceID         = convertToInt(orderItem['pHalf2SauceID'])
            half1SauceModifierID = convertToInt(orderItem['pHalf1SauceModifierID'])
            half2SauceModifierID = convertToInt(orderItem['pHalf2SauceModifierID'])

            # Hard coded sides as 8000 and above
            # Values originate in JSON, not the database
            # Added 8000 to original unit id (i.e. Vito's bread originally was UnitID 2, changed to 8002)
            # if(itemUnitId == 8000 || itemSpecialtyId == 8001)
            #     itemUnitId       = itemSpecialtyId - 8000
            #     itemSpecialtyId  = nil

            #     # UnitID 2 is Vito's bread...make sure all others don't have sauce (the SPROC will not like it)
            #     if(itemUnitId != 2)
            #         half1SauceID         = nil
            #         half2SauceID         = nil
            #         half1SauceModifierID = nil
            #         half2SauceModifierID = nil
            #     end
            # end

            orderItem['pUnitID']               = itemUnitId
            orderItem['pSpecialtyID']          = itemSpecialtyId
            orderItem['pSizeID']               = convertToInt(orderItem['pSizeID'])
            orderItem['pStyleID']              = convertToInt(orderItem['pStyleID'])
            orderItem['pHalf1SauceID']         = half1SauceID
            orderItem['pHalf2SauceID']         = half2SauceID
            orderItem['pHalf1SauceModifierID'] = half1SauceModifierID
            orderItem['pHalf2SauceModifierID'] = half2SauceModifierID
            orderItem['pOrderLineNotes']       = orderItem['pOrderLineNotes']
            orderItem['pInternetDescription']  = orderItem['pInternetDescription']
            # @NOTE: Quantity isn't relevant, create multiple line items for each pizza
            orderItem['pQuantity']             = 1

            # puts(JSON.pretty_generate(orderItem))

            orderItemResult = ActiveRecord::Base.connection.execute_procedure("AddOrderLine", orderItem);

            # OrderLineItem
            toppings = data['orderItemToppings']
            toppers = data['orderItemToppers']

            result['orderLineItemResults'] = Array.new
            result['orderLineToppers'] = Array.new
            orderLineItemResult            = Array.new

            if(toppings != nil && toppings.count > 0)
                toppings.each do |topping|
                    doubleRecord = false
                    orderLineItem = Hash.new
                    orderLineItem['pOrderLineID'] = convertToInt(orderItemResult[0]['newid'])
                    orderLineItem['pItemID'] = topping['id']
                    case topping['portion']
                    when 'whole' 
                        orderLineItem['pHalfID'] = '0'
                    when 'left'
                        orderLineItem['pHalfID'] = '1'
                    when 'right'
                        orderLineItem['pHalfID'] = '2'
                    when '2x'
                        orderLineItem['pHalfID'] = '0'
                        doubleRecord = true
                    else
                        orderLineItem['pHalfID'] = '0'
                    end
        
                    orderLineItemResult = ActiveRecord::Base.connection.execute_procedure("AddOrderLineItem", orderLineItem);
                    if doubleRecord != false
                        orderLineItemResult = ActiveRecord::Base.connection.execute_procedure("AddOrderLineItem", orderLineItem);
                    end
                    result['orderLineItemResults'].push(orderLineItemResult)
                end
            end
            if(toppers != nil && toppers.count > 0)
                toppers.each do |topper|
                    orderLineTopper = Hash.new
                    orderLineTopper['pOrderLineID'] = convertToInt(orderItemResult[0]['newid'])
                    orderLineTopper['pTopperID'] = topper
                    orderLineTopper['pTopperHalfID'] = 0
        
                    orderLineToppperResult = ActiveRecord::Base.connection.execute_procedure("AddOrderLineTopper", orderLineTopper);
                    result['orderLineToppers'].push(orderLineToppperResult)
                end
            end

            if(!data['orderItemSidesClean'].blank? && qtyPointer == 1)
                data['orderItemSidesClean']['purchased'].each do |side|
                    i = 0
                    # puts(side)
                    while i < side['qty'] and i < 20 do
                        ActiveRecord::Base.connection.execute_procedure("AddOrderLineSide", {
                            :pOrderLineID => convertToInt(orderItemResult[0]['newid']),
                            :pSideID => side['SideID'],
                            :pIsFreeSide => 0 
                        });
                        i += 1
                    end
                end
                data['orderItemSidesClean']['free'].each do |side|
                    i = 0
                    # puts(side)
                    while i < side['qty'] and i < 20 do
                        ActiveRecord::Base.connection.execute_procedure("AddOrderLineSide", {
                            :pOrderLineID => convertToInt(orderItemResult[0]['newid']),
                            :pSideID => side['SideID'],
                            :pIsFreeSide => 1
                        });
                        i += 1
                    end
                end
            end

            qtyPointer += 1
        end
        # Update Price
        updatePrice = {
            :pOrderID => orderId,
            :pStoreID => storeId,
            :pCouponIDs => session[:Coupons].blank? ? "" : session[:Coupons].join(','),
            :pPromoCodes => session[:Promos].blank? ? "" : session[:Promos].join(',')
        }

        updatePriceResult = ActiveRecord::Base.connection.execute_procedure("WebRecalculateOrderPrice", updatePrice)


        result['order']             = orderResult
        # result['orderItem']         = orderItemResult
        result['updatePriceResult'] = updatePriceResult

        return result.to_json
    end

    def self.updatePrice(session)
        updatePrice = {
            :pOrderID => session[:orderId],
            :pStoreID => session[:storeID],
            :pCouponIDs => session[:Coupons].blank? ? "" : session[:Coupons].join(','),
            :pPromoCodes => session[:Promos].blank? ? "" : session[:Promos].join(',')
        }

        ActiveRecord::Base.connection.execute_procedure("WebRecalculateOrderPrice", updatePrice)

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

