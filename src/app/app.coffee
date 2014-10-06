$app = angular.module('app', ['ngRoute','ui.router','restangular'])

$app.config ($stateProvider, $urlRouterProvider,RestangularProvider)->
  RestangularProvider.setBaseUrl('/api')
  $urlRouterProvider.otherwise("/")
  $stateProvider
    .state('home', {
      url:'/'
      template:'<div></div>'
      controller:()->
    })
    .state('detail', {
      url: "/detail/:unitId/:specialtyId",
      templateUrl: "app/partials/detail.html",
      resolve:
        $specialty: (Restangular,$stateParams)->
          Restangular.one('item').get
            "UnitID":  $stateParams.unitId
            "SpecialtyID":  $stateParams.specialtyId
            "SizeID":  null
      controller: ($scope,$specialty,$stateParams,$state,Restangular)->
        $scope.$sp = $specialty
        $scope.onMeat = true
        $scope.__orderingItem = false
        $scope.tab = 'size'
        $scope.$line = {SauceID:$specialty.specialty && $specialty.specialty.SauceID || null,SizeID:null,Sides:[],Toppings:[],StyleID:null,Toppers:[],Note:'',Quantity:1}
        $scope.$selectedSides = {}
        $scope.$selectedToppings = {}
        $scope.$selectedToppers = {}
        $UnitID = parseInt $stateParams.unitId
        if $specialty.styles.length is 0 and $specialty.sizes.length > 0
          $scope.$line.SizeID = $specialty.sizes[0].SizeID
        if $specialty.styles.length > 0 and !$scope.$line.StyleID
          $scope.$line.StyleID = $specialty.styles[0].StyleID
        # @NOTE: Ideally get these units flagged in the database for easier management later. is bread?
        $scope.isBread = ->
          if [1,2,32].indexOf($UnitID) isnt -1
            true
          else false
        $scope.calcPrice = (x)->
          if $specialty.specialty
            return x.SpecialtyBasePrice + (x.StyleSurcharge || 0)
          else
            return x.StandardBasePrice + (x.StyleSurcharge || 0)
        $scope.styleSurcharge = ()->
          for x in $scope.$sp.sizes
            if $scope.$line.SizeID == x.SizeID and x.StyleSurcharge > 0
              return x.StyleSurcharge
          return 0

        verifySelectedSize = (sizes)->
          return false if not sizes.length
          sel = false
          for x in sizes
            if x.SizeID is $scope.$line.SizeID
              sel = true
          if sel is false
            $scope.$line.SizeID = sizes[0].SizeID

        # @NOTE: @database flag toppings as cheese vs meat [github.com/tandpco/VitosWeb2/issues/13]
        $scope.filterCheese = (i)->
          return true if [10,12,13,49,52,53,59,60,84,104].indexOf(i.ItemID) isnt -1
          return false
        $scope.filterMeat = (i)->
          return false if [10,12,13,49,52,53,59,60,84,104].indexOf(i.ItemID) isnt -1
          return true if $scope.onMeat and [11,14,19,21,27,28,33,35,43,44,45,46,50,51,55,56,97,105].indexOf(i.ItemID) isnt -1
          return true if not $scope.onMeat and [11,14,19,21,27,28,33,35,43,44,45,46,50,51,55,56,97,105].indexOf(i.ItemID) is -1
          return false


        $scope.orderItem = ()->
          # orderId = Session.get("orderId")
          $scope.__orderingItem = true
          orderItemJson =
            # pOrderID: orderId
            pUnitID: $stateParams.unitId
            # speciality Id shouldn't be required
            pSpecialtyID: $stateParams.specialtyId
            pSizeID: $scope.$line.SizeID
            pStyleID: $scope.$line.StyleID
            pHalf1SauceID:$scope.$line.SauceID
            pHalf2SauceID: $scope.$line.SauceID
            pHalf1SauceModifierID: $scope.$line.sauceModifierID
            pHalf2SauceModifierID: $scope.$line.sauceModifierID
            # allow for notes on order line
            pOrderLineNotes: $scope.$line.Note
            # pInternetDescription: ((if not (orderItem["item"])? then "NULL" else orderItem["item"]["detail"]))
            pQuantity: $scope.$line.Quantity || 1

          # toppingsJson = $scope.$line.Toppings
          

          mode = 2
          deliveryMode = if mode is "Delivery" then "1" else "2"

          orderJson =
            pCustomerID: "6063" #deprecate
            pCustomerName: "Vito''s Fan" #deprecate
            pCustomerPhone: "1111111111" #deprecate
            pAddressID: "1" #deprecate
            pOrderTypeID: deliveryMode
            # pDeliveryCharge: Session.get("deliveryCharge") # seems wrong
            # pDriverMoney: Session.get("driverMoney") # tip??
            pOrderNotes: "" # should be updated seperately
          toppingsJson = []
          for x in $scope.$line.Toppings
            toppingsJson.push
              id: x['ItemID']
              portion: x['Portion']
          json =
            order: orderJson
            orderItem: orderItemJson
            # updatePrice: updatePriceJson
            orderItemToppings: toppingsJson
            orderItemToppers: $scope.$line.Toppers
            orderItemSides: $scope.$line.Sides

          URL = "/api/order"
          $.ajax
            url: URL
            type: "PUT"
            data: JSON.stringify(json)
            success: (data) ->
              console.log data
              $scope.__orderingItem = false
              $scope.$root.updateOrder()
              $scope.$apply()
              $state.go "home"
              # unless orderId?
              #   console.log "Created Order Id: " + data["order"][0]["newid"]
              #   Session.set "orderId", data["order"][0]["newid"]
              # orderItemId = data["orderItem"][0]["newid"]
              # orderItem["id"] = orderItemId
              # orderItems = JSON.parse(Session.get("orderItems"))
              # orderItems.push orderItem
              # Session.set "orderItems", JSON.stringify(orderItems)
              # pageController.listOrderItems()
              # return
        $scope.setSide = (side,value)->
          $scope.$selectedSides[side.SideID] = value
          $v ={already:false,remove:false}
          _.each $scope.$line.Sides,(val,key)->
            if val.SideID is side.SideID
              if value is false
                $v.remove = key
              else
                val.Quantity = parseInt value
              $v.already = true
          console.log side,value
          if $v.remove isnt false
            $scope.$line.Sides.splice($v.remove,1)
            console.log 'removed'
          if not $v.already
            $scope.$line.Sides.push {SideID:side.SideID,Quantity:parseInt value}
        $scope.setTopping = (topping,value,side)->
          if value
            $scope.$selectedToppings[topping.ItemID] = side
          else
            $scope.$selectedToppings[topping.ItemID] = false
          $v ={already:false,remove:false}
          _.each $scope.$line.Toppings,(val,key)->
            if val.ItemID is topping.ItemID
              if value is false
                $v.remove = key
              val.Portion = side
              $v.already = true

          console.log topping,value,$scope.$line.Toppings
          if $v.remove isnt false
            $scope.$line.Toppings.splice($v.remove,1)
            console.log 'removed'
          if not $v.already
            $scope.$line.Toppings.push {ItemID:topping.ItemID,Portion:side}

        $scope.setTopper = (topper,value)->
          $scope.$selectedToppers[topper.TopperID] = value && true || false
          exists = $scope.$line.Toppers.indexOf(topper.TopperID) != -1
          if not value and exists
            $scope.$line.Toppers.splice($scope.$line.Toppers.indexOf(topper.TopperID),1)
          if value and not exists
            $scope.$line.Toppers.push(topper.TopperID)


        if _.isArray $scope.$sp.specialtyDefaults
          for x in $scope.$sp.specialtyDefaults
            $scope.setTopping x,true,'whole'
        if not $specialty.NoBaseCheese
          for x in $specialty.toppings
            if x.IsBaseCheese
              $scope.setTopping x,true,'whole'

        # $scope.$watchCollection "$line.Sides",(v)->
        #   console.log 'chosen sides',v
        # $scope.$watchCollection "$line.Toppings",(v)->
        #   console.log 'chosen toppings',v
        $scope.$watch "$line.StyleID",(v)->
          if v
            $scope.checkingSizes = true
            Restangular.all("item-sizes").getList(
              "StoreID": "7"
              "UnitID":  $stateParams.unitId
              "SpecialtyID":  $stateParams.specialtyId
              "StyleID":  v
            ).then (v)->
              $scope.checkingSizes = false
              verifySelectedSize(v)
              $scope.$sp.sizes = v
    })

$app.run ($state,$rootScope,Restangular)->
  $scope = $rootScope
  $scope.$order = {}
  $scope.$lines = []
  $scope.$appliedCoupons = Restangular.all('applied-coupons').getList().$object
  $scope.__loadingOrder = true
  window.__itemDetail = (unitId,specialtyId)->
    $state.go('detail',{unitId:unitId,specialtyId:specialtyId})
  window.updateOrder = ()->
    $scope.updateOrder()
  $scope.deleteLineItem = ($line)->
    for $cl,$i in $scope.$lines
      if $cl.OrderLineID is $line.OrderLineID
        $scope.$lines.splice($i,1)
        # $scope.$apply()
        break
    $line.remove().then ()->
      $scope.__loadingOrder = true
      Restangular.one("order").get().then ($order)->
        $scope.$order = $order
        $scope.__loadingOrder = false
    updateSubtotal($scope.$lines)

  $scope.adjustUnitName = (d)->
    if d.unit.UnitID is 15
      return d.size.SizeDescription + ' ' + d.style.StyleDescription
    if d.unit.UnitID is 7
      return d.size.SizeDescription + ' ' + d.unit.UnitDescription
    if d.specialty?
      return d.specialty.SpecialtyShortDescription + ' ' + d.unit.UnitDescription
    if d.unit.UnitID is 1
      return "Build your Own Pizza"
    return d.unit.UnitDescription
  $scope.sizePretty = (size)->
    if !size?
      return '•'
    out = ""
    if size.indexOf(' ') isnt -1
      words = size.split(' ')
      if /^[0-9]+$/.test(words.slice(-1)[0])
        return words.slice(-1)[0]
      for i in words
        out += i.substr(0,1)
      return out
    out = size.substr(0,2)
    if out.toLowerCase() is 'me' 
      return 'MD'
    return out
      
  $scope.showSubmit = ()->
    if window.location.pathname == '/order' || window.location.pathname == '/locations'
      return true
    false
  $scope.halfPretty = (half)->
    half = parseInt half
    halfs = ['Whole','Left','Right','2x']
    return halfs[half]
  $scope.updateOrder = ()->
    $scope.__loadingOrder = true
    Restangular.one("order").get().then ($order)->
      # console.log 'order',v
      $scope.$order = $order
      if not angular.isFunction $order.getList
        $scope.__loadingOrder = false
        return
      $order.getList('lines').then ($items)->
        $scope.$lines = $items
        updateSubtotal($scope.$lines)
        $scope.__loadingOrder = false
      .catch ()->
        $scope.__loadingError = true
        $scope.__loadingOrder = false
    .catch ()->
      $scope.__loadingError = true
      $scope.__loadingOrder = false
  # $scope.$watchCollection "$lines", updateSubtotal
  updateSubtotal = ($items)->
    if $items.length > 0
      total = 0
      for item in $items
        total += item.Cost - item.Discount
      $scope.$orderSubtotal = total
  $scope.$orderTotal = 0
  updateTotal = (v)->
    if $scope.$orderSubtotal? and $scope.$orderSubtotal > 0
      $scope.$orderTotal = $scope.$orderSubtotal + $scope.$order.Tax + $scope.$order.Tax2 + parseInt(if $scope.$order.Tip == '' then 0 else $scope.$order.Tip) + $scope.$order.DeliveryCharge
      
  $scope.$watch "$orderSubtotal", updateTotal
  $scope.$watch "$order.Tip", updateTotal
  $scope.$watch "$order.Tip", (v,o)->
    if o?
      $scope.$order.customPOST {tip:v},'update-tip'
  $scope.updateOrder()

  return