(function() {
  var $app;

  $app = angular.module('app', ['ngRoute', 'ui.router', 'restangular']);

  $app.config(function($stateProvider, $urlRouterProvider, RestangularProvider) {
    RestangularProvider.setBaseUrl('/api');
    return $stateProvider.state('detail', {
      url: "/detail/:unitId/:specialtyId",
      templateUrl: "partials/detail.html",
      resolve: {
        $specialty: function(Restangular, $stateParams) {
          return Restangular.one('item').get({
            "StoreID": "7",
            "UnitID": $stateParams.unitId,
            "SpecialtyID": $stateParams.specialtyId,
            "SizeID": "null"
          });
        }
      },
      controller: function($scope, $specialty, $stateParams) {
        $scope.$sp = $specialty;
        $scope.$line = {
          SauceID: null,
          SizeID: null,
          Sides: [],
          Toppings: [],
          StyleID: null,
          notes: ''
        };
        $scope.$selectedSides = {};
        $scope.$selectedToppings = {};
        $scope.orderItem = function() {
          var URL, dateString, deliveryMode, json, mode, now, orderId, orderItemJson, orderJson, updatePriceJson;
          orderId = Session.get("orderId");
          orderItemJson = {
            pOrderID: orderId,
            pUnitID: $stateParams.unitId,
            pSpecialtyID: $stateParams.specialtyId,
            pSizeID: $scope.$line.SizeID,
            pStyleID: $scope.$line.StyleID,
            pHalf1SauceID: $scope.$line.SauceID,
            pHalf2SauceID: $scope.$line.SauceID,
            pHalf1SauceModifierID: $scope.$line.sauceModifierID,
            pHalf2SauceModifierID: $scope.$line.sauceModifierID,
            pOrderLineNotes: $scope.$line.notes,
            pQuantity: $scope.$line.Quantity
          };
          updatePriceJson = {
            pStoreID: Session.get("storeId"),
            pOrderID: Session.get("orderId")
          };
          now = new Date();
          dateString = now.toISOString();
          mode = Session.get("mode");
          deliveryMode = 0;
          if (mode === "Delivery") {
            deliveryMode = "1";
          } else {
            deliveryMode = "2";
          }
          orderJson = {
            pOrderID: orderId,
            pSessionID: "999999999",
            pIPAddress: "0.0.0.0",
            pEmpID: "1",
            pRefID: "NULL",
            pTransactionDate: dateString,
            pStoreID: Session.get("storeId"),
            pCustomerID: "6063",
            pCustomerName: "Vito''s Fan",
            pCustomerPhone: "1111111111",
            pAddressID: "1",
            pOrderTypeID: deliveryMode,
            pDeliveryCharge: Session.get("deliveryCharge"),
            pDriverMoney: Session.get("driverMoney"),
            pOrderNotes: ""
          };
          json = {
            order: orderJson,
            orderItem: orderItemJson,
            updatePrice: updatePriceJson,
            orderItemToppings: orderItemToppingsJson
          };
          URL = "/rest/view/order/create-order";
          console.log(URL, json);
          return $.ajax({
            url: URL,
            type: "POST",
            data: JSON.stringify(json),
            success: function(data) {
              var orderItemId, orderItems;
              if (orderId == null) {
                console.log("Created Order Id: " + data["order"][0]["newid"]);
                Session.set("orderId", data["order"][0]["newid"]);
              }
              orderItemId = data["orderItem"][0]["newid"];
              orderItem["id"] = orderItemId;
              orderItems = JSON.parse(Session.get("orderItems"));
              orderItems.push(orderItem);
              Session.set("orderItems", JSON.stringify(orderItems));
              pageController.listOrderItems();
            }
          });
        };
        $scope.setSide = function(side, value) {
          var $v;
          $v = {
            already: false,
            remove: false
          };
          _.each($scope.$line.Sides, function(val, key) {
            if (val.SideID === side.SideID) {
              if (value === false) {
                $v.remove = key;
              }
              return $v.already = true;
            }
          });
          console.log(side, value);
          if ($v.remove !== false) {
            $scope.$line.Sides.splice($v.remove, 1);
            console.log('removed');
          }
          if (!$v.already) {
            return $scope.$line.Sides.push({
              SideID: side.SideID,
              Quantity: 1
            });
          }
        };
        $scope.setTopping = function(topping, value) {
          var $v;
          $v = {
            already: false,
            remove: false
          };
          _.each($scope.$line.Toppings, function(val, key) {
            if (val.ItemID === topping.ItemID) {
              if (value === false) {
                $v.remove = key;
              }
              val.Portion = value;
              return $v.already = true;
            }
          });
          console.log(topping, value, $scope.$line.Toppings);
          if ($v.remove !== false) {
            $scope.$line.Toppings.splice($v.remove, 1);
            console.log('removed');
          }
          if (!$v.already) {
            return $scope.$line.Toppings.push({
              ItemID: topping.ItemID,
              Portion: value
            });
          }
        };
        $scope.$watchCollection("$line.Sides", function(v) {
          return console.log('chosen sides', v);
        });
        $scope.$watchCollection("$line.Toppings", function(v) {
          return console.log('chosen toppings', v);
        });
        return $scope.$watch("$line.SizeID", function(v) {
          if (v) {
            return $scope.$sp.get({
              "StoreID": "7",
              "UnitID": $stateParams.unitId,
              "SpecialtyID": $stateParams.specialtyId,
              "SizeID": v
            }).then(function(v) {
              return $scope.$sp = v;
            });
          }
        });
      }
    });
  });

  $app.run(function($state) {
    window.__itemDetail = function(unitId, specialtyId) {
      return $state.go('detail', {
        unitId: unitId,
        specialtyId: specialtyId
      });
    };
  });

}).call(this);
