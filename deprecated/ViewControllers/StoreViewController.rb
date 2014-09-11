require 'time'

class StoreViewController
    public

    def self.getStore(data)
        storeId      = data['storeId'].to_s
        streetNumber = data['streetNumber']
        streetName   = data['streetName']
        zip          = data['zip']

        storeData = ActiveRecord::Base.connection.select_all('select * from tblStores where storeid = ' + storeId + ' AND 1 = 1')

        now  = Time.new()

        isOpen = false
        if(storeData.count > 0)
            nTime = now.hour * 100 + now.min
            open  = 0
            close = 0
            case now.wday 
                when 0
                    open = storeData[0]['OpenSun']
                    close = storeData[0]['CloseSun']
                when 1
                    open = storeData[0]['OpenMon']
                    close = storeData[0]['CloseMon']
                when 2
                    open = storeData[0]['OpenTue']
                    close = storeData[0]['CloseTue']
                when 3
                    open = storeData[0]['OpenWed']
                    close = storeData[0]['CloseWed']
                when 4
                    open = storeData[0]['OpenThu']
                    close = storeData[0]['CloseThu']
                when 5
                    open = storeData[0]['OpenFri']
                    close = storeData[0]['CloseFri']
                when 6
                    open = storeData[0]['OpenSat']
                    close = storeData[0]['CloseSat']
            end

            if(nTime >= open && nTime <= 2400) or (nTime >= 0 && nTime <= close)
                isOpen = true
            end

            storeData[0]['IsOpen'] = isOpen

            sql = 'select distinct tblCASSAddresses.storeid, tblCASSAddresses.street, tblCASSAddresses.city, tblCASSAddresses.state, tblCASSAddresses.deliverycharge, tblCASSAddresses.drivermoney from tblCASSAddresses inner join tblStores on tblCASSAddresses.storeid = tblStores.storeid where tblStores.storeid = ' + storeId + ' and tblCASSAddresses.postalcode = \'' + zip + '\' and tblCASSAddresses.street like \'' + streetName + '%\' and tblCASSAddresses.lownumber <= ' + streetNumber + ' and tblCASSAddresses.highnumber >= ' + streetNumber + ' AND 1 = 1'
            deliveryData = ActiveRecord::Base.connection.select_all(sql)

            puts("SQL: #{sql}")
            puts("Delivery Data: #{deliveryData.to_json}")

            if(deliveryData.count > 0)
                storeData[0]['DefaultDeliveryCharge'] = deliveryData[0]['deliverycharge']
                storeData[0]['DefaultDriverMoney']    = deliveryData[0]['drivermoney']
            end
        end

        return storeData.to_json
    end

    def self.listStores(data)
        email     = data['email']
        password  = data['password']

        rows = ActiveRecord::Base.connection.select_all('select * from tblStores where storeid > 0 AND 1 = 1')

        return rows.to_json
    end

end

