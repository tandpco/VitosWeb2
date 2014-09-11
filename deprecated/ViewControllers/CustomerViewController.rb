class CustomerViewController
    public


    def self.getCustomer(data)
        email     = data['email']
        password  = data['password']

        rows = ActiveRecord::Base.connection.select_all('select tblCustomers.CustomerID, EMail, FirstName, LastName, CellPhone, Birthdate, PrimaryAddressID, CustomerAddressDescription, AddressLine1, AddressLine2, City, State, PostalCode, CustomerAddressNotes from tblCustomers inner join trelCustomerAddresses on tblCustomers.CustomerID = trelCustomerAddresses.CustomerID and tblCustomers.PrimaryAddressID = trelCustomerAddresses.AddressID inner join tblAddresses on trelCustomerAddresses.AddressID = tblAddresses.AddressID where EMail = \'' + email + '\' and Password = \'' + password + '\'')

        return rows.to_json
    end

end

