$app = angular.module('app', ['ngRoute','ui.router','restangular'])

# Console-polyfill. MIT license.
# https://github.com/paulmillr/console-polyfill
# Make it safe to do console.log() always.
((con) ->
  "use strict"
  prop = undefined
  method = undefined
  empty = {}
  dummy = ->

  properties = "memory".split(",")
  methods = ("assert,clear,count,debug,dir,dirxml,error,exception,group," + "groupCollapsed,groupEnd,info,log,markTimeline,profile,profiles,profileEnd," + "show,table,time,timeEnd,timeline,timelineEnd,timeStamp,trace,warn").split(",")
  con[prop] = con[prop] or empty  while prop = properties.pop()
  con[method] = con[method] or dummy  while method = methods.pop()
  return
) @console = @console or {} # Using `this` for web workers.


$app.config ($stateProvider, $urlRouterProvider,RestangularProvider)->
  RestangularProvider.setBaseUrl('/api')
  RestangularProvider.setFullRequestInterceptor (element, operation, what, url, headers, params) ->
    headers: headers
    params: _.extend(params,
      cacheKilla: new Date().getTime()
    )
    element: element

  $urlRouterProvider.otherwise("/")
  $stateProvider
    .state('home', {
      url:'/'
      template:'<div></div>'
      controller:()->
    })
    .state('detail', {
      url: "/detail/:unitId/:specialtyId?coupon",
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
        $scope.$line.UnitID = $UnitID

        if $specialty.styles.length is 0 and $specialty.sizes.length > 0
          $scope.$line.SizeID = $specialty.sizes[0].SizeID
        if $specialty.styles.length > 0 and !$scope.$line.StyleID
          $scope.$line.StyleID = $specialty.styles[0].StyleID



        if $stateParams.coupon
          $coupon = $scope.$root.getCoupon($stateParams.coupon)
          $scope.$coupon = $coupon
          if $coupon
            $to = $coupon.AppliesTo[0]
            if $to.StyleID
              $scope.$line.StyleID = $to.StyleID
            if $to.SizeID
              $scope.$line.SizeID = $to.SizeID
          console.log $coupon
        # @NOTE: Ideally get these units flagged in the database for easier management later. is bread?
        $scope.isBread = ->
          if [1,2,32].indexOf($UnitID) isnt -1
            true
          else false
        freeColors = ["#800080","#008000","#804000","#0080ff","#d75c00"]
        $scope.isFreeSide = ($side)->
          for sg in $scope.$sp.defaultSideGroups
            for s in sg.sides
              return true if s.SideID is $side.SideID
          return false
        $scope.freeSideStyle = ($side)->
          for sg,i in $scope.$sp.defaultSideGroups
            color = freeColors[i]
            for s in sg.sides
              return {'background-color':color} if s.SideID is $side.SideID
          return {}
        $scope.freeSideCount = ($side)->
          for sg in $scope.$sp.defaultSideGroups
            if parseInt($scope.$line.Quantity) > 1
              sQuantity = sg.Quantity * $scope.$line.Quantity
            else
              sQuantity = sg.Quantity
            for s in sg.sides
              return sg.sides.length is 1 && 1 || 'any '+sQuantity if s.SideID is $side.SideID
          return 0
        theSideGroup = (sid)->
          for sg,i in $scope.$sp.defaultSideGroups
            for s in sg.sides
              return i if s.SideID is sid
          return false
        # $scope.sides = angular.copy($scope.$sp.extraSides)
        $scope.$sp.extraSides.sort (a,b)->
          return -1 if a.SidePrice < b.SidePrice
          return 1 if a.SidePrice > b.SidePrice
          0
        $scope.$sp.extraSides.reverse()
        $scope.sideTotal = ()->
          sides = $scope.$sp.extraSides
          possibles = []
          for x,i in $scope.$sp.defaultSideGroups
            if parseInt($scope.$line.Quantity) > 1
              sQuantity = x.Quantity * $scope.$line.Quantity
            else
              sQuantity = x.Quantity
            possibles[i] = {qty:0,max:sQuantity}
          # console.log possibles
          purchases = []
          free = []
          for s in sides
            s.buy = 0
            if typeof $scope.$selectedSides[s.SideID] is 'string' && $scope.$selectedSides[s.SideID] > 0
              sg = theSideGroup(s.SideID)
              sq = parseInt($scope.$selectedSides[s.SideID])
              if sg isnt false
                if(possibles[sg].max is possibles[sg].qty)
                  purchases.push({SideID:s.SideID,qty:sq,price:s.SidePrice})
                  s.buy = sq
                else if(possibles[sg].max < sq+possibles[sg].qty)
                  ex = (sq+possibles[sg].qty)-possibles[sg].max
                  s.buy = ex
                  free.push({SideID:s.SideID,qty:sq-ex})
                  possibles[sg].qty = possibles[sg].max
                  purchases.push({SideID:s.SideID,qty:ex,price:s.SidePrice})
                else
                  free.push({SideID:s.SideID,qty:sq})
                  possibles[sg].qty += sq
              else
                purchases.push({SideID:s.SideID,qty:sq,price:s.SidePrice})

          total = 0
          # console.log purchases,possibles,$scope.$selectedSides
          $scope.$line.sideBuy = {free:free,purchased:purchases}
          for x in purchases
            total += x.qty * x.price
          return total

        $scope.calcPrice = (x)->
          if $specialty.specialty
            $out = x.SpecialtyBasePrice + (x.StyleSurcharge || 0)
          else
            $out = x.StandardBasePrice + (x.StyleSurcharge || 0)
          return $out

        $scope.couponPrice = (x)->
          if not x?
            for size in $scope.$sp.sizes
              if size.SizeID is $scope.$line.SizeID
                x = size
                break
          $price = $scope.calcPrice x
          $coupon = $scope.$coupon
          if not $coupon
            return null
          if x.SizeID
            for $for in $coupon.AppliesTo
              if $for.SizeID is x.SizeID and $for.UnitID is x.UnitID
                if $for.FixedPrice
                  $out = $for.FixedPrice
                if $for.DollarOff
                  $out = $price - $for.DollarOff
                if x.SpecialtyID
                  $out += $for.AddForSpecialty
                return $out
          return null
    
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
          if $scope.__orderingItem is true
            return
          if $scope.$parent.$lines.length >=15
            return alert "You can only add 15 items to your order."
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
            pHalf1SauceModifierID: $scope.$line.SauceModifierID
            pHalf2SauceModifierID: $scope.$line.SauceModifierID
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
            orderItemSidesClean: $scope.$line.sideBuy

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
          # console.log side,value
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
            $scope.setTopping x,true,x.SpecialtyItemQuantity is 2 && '2x' || 'whole'
        if not $specialty.NoBaseCheese
          for x in $specialty.toppings
            if x.IsBaseCheese
              $scope.setTopping x,true,x.SpecialtyItemQuantity is 2 && '2x' || 'whole'

        # $scope.$watchCollection "$line.Sides",(v)->
        #   console.log 'chosen sides',v
        # $scope.$watchCollection "$line.Toppings",(v)->
        #   console.log 'chosen toppings',v
        $scope.$watch "$line.StyleID",(v)->
          if v
            $scope.checkingSizes = true
            Restangular.all("item-sizes").getList(
              "UnitID":  $stateParams.unitId
              "SpecialtyID":  $stateParams.specialtyId
              "StyleID":  v
            ).then (v)->
              $scope.checkingSizes = false
              verifySelectedSize(v)
              $scope.$sp.sizes = v
        $scope.$watch "$line.SizeID",(v)->
          if v
            Restangular.all("item-sides").getList(
              "UnitID":  $stateParams.unitId
              "SizeID":  v
            ).then (v)->
              $scope.$sp.defaultSideGroups = v
    })

$app.run ($state,$rootScope,Restangular)->
  $scope = $rootScope
  $scope.$order = {}
  $scope.$lines = []
  $scope.$promoCode = ""
  # $scope.$appliedCoupons = Restangular.all('applied-coupons').getList().$object
  $scope.__loadingOrder = true
  window.__itemDetail = (unitId,specialtyId)->
    $state.go('detail',{unitId:unitId,specialtyId:specialtyId})
  window.updateOrder = ()->
    $scope.updateOrder()

  $scope.$applyPromo = ()->
    # console.log $scope.$promoCode
    if $scope.$promoCode.length > 1
      $scope.$order.customPOST({CouponCode:$scope.$promoCode},'add-promo').then ()->
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

  # $scope.groupSides = ($sg)->
  #   # console.log '==>',$sg
  #   $out = {}
  #   for $side in $sg
  #     if not $out[$side.SideDescription]    
  #       $out[$side.SideDescription] = 1
  #     else
  #       $out[$side.SideDescription] += 1
  #   $ret = []
  #   angular.forEach $out, (value, key) ->
  #     $ret.push({SideDescription:key,Quantity:value})
  #   # console.log $ret
  #   return $ret
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
  
  $scope.getCoupon = (id)->
    for $coupon in $scope.$appliedCoupons
      if $coupon.CouponID is parseInt(id)
        return $coupon
    return null  
  $scope.showSubmit = ()->
    if window.location.pathname == '/order' || window.location.pathname == '/locations' || window.location.pathname == '/deals'
      return true
    false
  $scope.halfPretty = (half)->
    half = parseInt half
    halfs = ['Whole','Left','Right','2x']
    return halfs[half]
  $scope.updateOrder = ()->
    $scope.__loadingOrder = true
    $scope.$appliedCoupons = []
    Restangular.all('applied-coupons').getList().then (v)->
      $scope.$appliedCoupons = v
    Restangular.one("order").get().then(($order)->
      # alert $order.OrderID
      # console.log 'order',v
      $scope.$order = $order
      if not angular.isFunction $order.getList
        $scope.__loadingOrder = false
        if $scope.$appliedCoupons.length
          $coupon = $scope.$appliedCoupons[0]
          $to = $coupon.AppliesTo[0]
          $state.go 'detail', {unitId:$to.UnitID,specialtyId:$to.SpecialtyID,coupon:$coupon.CouponID}
        return
      $order.getList('lines').then(($items)->
        # alert $items.length + ' Items'
        $scope.$lines = $items
        updateSubtotal($scope.$lines)
        $scope.__loadingOrder = false

        
      , ()->
        $scope.__loadingError = true
        $scope.__loadingOrder = false
      )
    ,()->
      $scope.__loadingError = true
      $scope.__loadingOrder = false
    )
  # $scope.$watchCollection "$lines", updateSubtotal
  updateSubtotal = ($items)->
    if $items.length > 0
      total = 0
      for item in $items
        total += item.Quantity * (item.Cost - item.Discount)
      $scope.$orderSubtotal = total
  $scope.$orderTotal = 0
  updateTotal = (v)->
    if $scope.$orderSubtotal? and $scope.$orderSubtotal > 0
      $scope.$orderTotal = $scope.$orderSubtotal + $scope.$order.Tax + $scope.$order.Tax2 + parseInt(if $scope.$order.Tip == '' then 0 else $scope.$order.Tip) + $scope.$order.DeliveryCharge
      # alert $scope.$orderTotal
      
  $scope.$watch "$orderSubtotal", updateTotal
  $scope.$watch "$order.Tip", updateTotal
  $scope.$watch "$order.Tip", (v,o)->
    if o?
      $scope.$order.customPOST {tip:v},'update-tip'
  $scope.updateOrder()

  return