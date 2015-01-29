class Hacks
  public

  def self.storeIsClosed(store)
    time = Time.now.getlocal('-05:00')
    # time.getlocal('-05:00');
    hour = time.strftime('%H%M')
    puts('time: '+time.strftime('%H%M %z'))
    if time.sunday?
      open = store[:OpenSun]
      close = store[:CloseSun]
    elsif time.monday?
      open = store[:OpenMon]
      close = store[:CloseMon]
    elsif time.tuesday?
      open = store[:OpenTue]
      close = store[:CloseTue]
    elsif time.wednesday?
      open = store[:OpenWed]
      close = store[:CloseWed]
    elsif time.thursday?
      open = store[:OpenThu]
      close = store[:CloseThu]
    elsif time.friday?
      open = store[:OpenFri]
      close = store[:CloseFri]
    elsif time.saturday?
      open = store[:OpenSat]
      close = store[:CloseSat]
    end
    
    open_h = (open.to_f / 100.0).to_f.floor
    open_m = (((open.to_f / 100.0)-open_h)*100.0).floor
    open_f = open_h.to_s+':'+open_m.to_s.rjust(2,'0')
    close_h = (close.to_f / 100.0).to_f.floor
    close_m = (((close.to_f / 100.0)-close_h)*100.0).floor
    close_f = close_h.to_s+':'+close_m.to_s.rjust(2,'0')
    puts('open: '+open.to_s)
    puts('close: '+close.to_s)
    if hour.to_i < open.to_i  && (close.to_i > open.to_i || hour.to_i > close.to_i)
      return {:open => open_f,:close => close_f, :status => -1};
    end
    if hour.to_i > close.to_i && (close.to_i > open.to_i || hour.to_i < open.to_i)
      return {:open => open_f,:close => close_f, :status => 1};
    end

    return {:open => open_f,:close => close_f, :status => 0};
  end
  def self.totalOrder(order)
    subs = OrderLineViewController.getOrderSubtotal(order[:OrderID])
    puts(subs)
    subtotal = subs['Cost'] - subs['Discount']
    total = subtotal + order[:Tax] + order[:Tax2] + order[:Tip] + order[:DeliveryCharge]
    return total
  end
  def self.getStoreByAddress(pieces)
    query = ["select distinct tblCASSAddresses.StoreID from tblCASSAddresses where tblCASSAddresses.storeid > 0 and tblCASSAddresses.postalcode = '#{pieces['zipcode']}' and tblCASSAddresses.street like '" +getAddressStreet(pieces,{:streetonly =>true})+ "%'"]
    if !pieces["primary_number"].nil?
      query.push("and tblCASSAddresses.lownumber <= '#{pieces['primary_number']}' and tblCASSAddresses.highnumber >= '#{pieces['primary_number']}'")
    end
    puts(query.join(" "))
    store = ActiveRecord::Base.connection.select_all(query.join(" ")).first
    if !store.nil? and !store["StoreID"].nil?
      return Store.find(store["StoreID"])
    end
    return nil
  end
  def self.findOrCreateAddress(pieces,store)
    if getAddressSecondary(pieces)
      address = Address.where("AddressLine1 LIKE ?",getAddressStreet(pieces)+'%').where(AddressLine2: getAddressSecondary(pieces),City: pieces["city_name"].upcase,State: pieces["state_abbreviation"].upcase, PostalCode: pieces["zipcode"].upcase).first
    else
      address = Address.where("AddressLine1 LIKE ?",getAddressStreet(pieces)+'%').where(City: pieces["city_name"].upcase,State: pieces["state_abbreviation"].upcase, PostalCode: pieces["zipcode"].upcase).first
    end

    if address.nil?
      newAddress = {
        'pStoreID' => !store.nil? && store['StoreID'] || nil,
        'pAddressLine1' => Hacks.getAddressStreet(pieces,{:postdirection => true}),
        'pAddressLine2' => Hacks.getAddressSecondary(pieces),
        'pCity' => pieces["city_name"].upcase,
        'pState' => pieces["state_abbreviation"].upcase,
        'pPostalCode' => pieces["zipcode"],
        'pAddressNotes' => nil,
        'pIsManual' => 0,
      }
      newa = ActiveRecord::Base.connection.execute_procedure("AddAddress",newAddress)
      return Address.find(newa[0]['newid'])
    else
      return address
    end
  end
  def self.getAddressStreet(pieces,options = {})

        __street = []
        if !pieces["primary_number"].nil? and options[:streetonly].blank?
          __street.push(pieces["primary_number"])
        end
        if !options[:predirection].blank? and !pieces["street_predirection"].nil?
          __street.push(pieces["street_predirection"])
        end
        __street.push(pieces["street_name"])

        if(!pieces["street_suffix"].nil?)
          __street.push(pieces["street_suffix"])
        end
        if !options[:postdirection].blank? and !pieces["street_postdirection"].nil?
          __street.push(pieces["street_postdirection"])
        end
        return __street.join(" ").upcase
  end
  def self.getAddressSecondary(pieces)
    if !pieces["secondary_number"].nil?
      return pieces["secondary_number"].to_s.upcase
    end
    return nil
  end
  def self.specialtyImages(spec,unit)
    # @NOTE: get photos for the different subs and salads to put into play. [github.com/tandpco/VitosWeb2/issues/8]
    assoc = {
      5     => "Supreme300x300.jpg",
      6     => "TheWorks300x300.jpg",
      7     => "PepperoniPleas300x300.jpg",
      8     => "CHEESEBURGER3000x300.jpg",
      9     => "Hawaiian3000x300.jpg",
      10    => "Taco3000x300.jpg",
      11    => "Veggie300x300.jpg",
      12    => "BLT3000x300.jpg",
      13    => "BBQ3000x300.jpg",
      14    => "Mediterranean3000x300.jpg",
      16    => "ChickenBaconRanch3000x300.jpg",
      19    => "ChickenChipotle3000x300.jpg",
      22    => "TheWorks300x300.jpg",
      94    => "TonyPackos300x300.jpg",
      # 99    => "Brat300x300.jpg",
      99    => "TripleSausage300x300.jpg",
      100    => "Spud300x300.jpg",
      27    => "ItalianFoldoverSub300x300.jpg",
      28    => "PizzaSub3000x300.jpg",
      29    => "ChickenBreastSub3000x300.jpg",
      30    => "BBQChickenSub300x300.jpg",
      32    => "ClassicClubSub3000x300.jpg",
      33    => "Ham&CheeseSub3000x300.jpg",
      36    => "VeggieSub3000x300.jpg",
      37    => "TonyPackoSub3000x300.jpg",
      44    => "TacoSub3000x300.jpg",
      45    => "BLTSub3000x300.jpg",
      38    => "ChickenSalad3000x300.jpg",
      39    => "GreekSalad3000x300.jpg",
      40    => "ItalianSalad3000x300.jpg",
      41    => "salads-background.jpg",
      42    => "VitoSalad3000x300.jpg",
      8002  => "VitoBread300x300.jpg",
      8004  => "ChickenWings300x300.jpg",
      8005  => "CinnamonBread300x300.jpg",
      8007  => "ChickenDippers300x300.jpg",
      8015  => "CokeEtc300x300.jpg"
    }

    # Unit photos
    uassoc = {
      1     => "background.jpg",
      3     => "buildyourownsalad.jpg",  # @NOTE: replace build salad, wings, dippers, bread with real or purchased photo, stolen from google images currently [github.com/tandpco/VitosWeb2/issues/9]
      14    => "buildyourownsalad.jpg", 
      5     => "CinnamonBread300x300.jpg", 
      4     => "ChickenWings300x300.jpg",
      15    => "CokeEtc300x300.jpg",
      7     => "ChickenDippers300x300.jpg",
      2     => "VitoBread300x300.jpg" 
    }
    if spec.blank? and !unit.blank? then return uassoc[unit].blank? ? uassoc[1] : uassoc[unit] end

    return assoc[spec].blank? ? 'DefaultImage300x300.jpg' : assoc[spec]
  end

end