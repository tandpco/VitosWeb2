(function() {
  var $app;

  $app = angular.module('app', ['ngRoute', 'ui.router', 'restangular']);

  $app.config(function($stateProvider, $urlRouterProvider, RestangularProvider) {
    RestangularProvider.setBaseUrl('/api');
    $urlRouterProvider.otherwise("/");
    return $stateProvider.state('home', {
      url: '/',
      template: '<div></div>',
      controller: function() {}
    }).state('detail', {
      url: "/detail/:unitId/:specialtyId",
      templateUrl: "app/partials/detail.html",
      resolve: {
        $specialty: function(Restangular, $stateParams) {
          return Restangular.one('item').get({
            "UnitID": $stateParams.unitId,
            "SpecialtyID": $stateParams.specialtyId,
            "SizeID": null
          });
        }
      },
      controller: function($scope, $specialty, $stateParams, $state, Restangular) {
        var $UnitID, freeColors, theSideGroup, verifySelectedSize, x, _i, _j, _len, _len1, _ref, _ref1;
        $scope.$sp = $specialty;
        $scope.onMeat = true;
        $scope.__orderingItem = false;
        $scope.tab = 'size';
        $scope.$line = {
          SauceID: $specialty.specialty && $specialty.specialty.SauceID || null,
          SizeID: null,
          Sides: [],
          Toppings: [],
          StyleID: null,
          Toppers: [],
          Note: '',
          Quantity: 1
        };
        $scope.$selectedSides = {};
        $scope.$selectedToppings = {};
        $scope.$selectedToppers = {};
        $UnitID = parseInt($stateParams.unitId);
        if ($specialty.styles.length === 0 && $specialty.sizes.length > 0) {
          $scope.$line.SizeID = $specialty.sizes[0].SizeID;
        }
        if ($specialty.styles.length > 0 && !$scope.$line.StyleID) {
          $scope.$line.StyleID = $specialty.styles[0].StyleID;
        }
        $scope.isBread = function() {
          if ([1, 2, 32].indexOf($UnitID) !== -1) {
            return true;
          } else {
            return false;
          }
        };
        freeColors = ["#800080", "#008000", "#804000", "#0080ff", "#d75c00"];
        $scope.isFreeSide = function($side) {
          var s, sg, _i, _j, _len, _len1, _ref, _ref1;
          _ref = $scope.$sp.defaultSideGroups;
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            sg = _ref[_i];
            _ref1 = sg.sides;
            for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
              s = _ref1[_j];
              if (s.SideID === $side.SideID) {
                return true;
              }
            }
          }
          return false;
        };
        $scope.freeSideStyle = function($side) {
          var color, i, s, sg, _i, _j, _len, _len1, _ref, _ref1;
          _ref = $scope.$sp.defaultSideGroups;
          for (i = _i = 0, _len = _ref.length; _i < _len; i = ++_i) {
            sg = _ref[i];
            color = freeColors[i];
            _ref1 = sg.sides;
            for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
              s = _ref1[_j];
              if (s.SideID === $side.SideID) {
                return {
                  'background-color': color
                };
              }
            }
          }
          return {};
        };
        $scope.freeSideCount = function($side) {
          var s, sg, _i, _j, _len, _len1, _ref, _ref1;
          _ref = $scope.$sp.defaultSideGroups;
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            sg = _ref[_i];
            _ref1 = sg.sides;
            for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
              s = _ref1[_j];
              if (s.SideID === $side.SideID) {
                return sg.sides.length === 1 && 1 || 'any ' + sg.Quantity;
              }
            }
          }
          return 0;
        };
        theSideGroup = function(sid) {
          var i, s, sg, _i, _j, _len, _len1, _ref, _ref1;
          _ref = $scope.$sp.defaultSideGroups;
          for (i = _i = 0, _len = _ref.length; _i < _len; i = ++_i) {
            sg = _ref[i];
            _ref1 = sg.sides;
            for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
              s = _ref1[_j];
              if (s.SideID === sid) {
                return i;
              }
            }
          }
          return false;
        };
        $scope.$sp.extraSides.sort(function(a, b) {
          if (a.SidePrice < b.SidePrice) {
            return -1;
          }
          if (a.SidePrice > b.SidePrice) {
            return 1;
          }
          return 0;
        });
        $scope.$sp.extraSides.reverse();
        $scope.sideTotal = function() {
          var ex, free, i, possibles, purchases, s, sg, sides, sq, total, x, _i, _j, _k, _len, _len1, _len2, _ref;
          sides = $scope.$sp.extraSides;
          possibles = [];
          _ref = $scope.$sp.defaultSideGroups;
          for (i = _i = 0, _len = _ref.length; _i < _len; i = ++_i) {
            x = _ref[i];
            possibles[i] = {
              qty: 0,
              max: x.Quantity
            };
          }
          purchases = [];
          free = [];
          for (_j = 0, _len1 = sides.length; _j < _len1; _j++) {
            s = sides[_j];
            s.buy = 0;
            if (typeof $scope.$selectedSides[s.SideID] === 'string' && $scope.$selectedSides[s.SideID] > 0) {
              sg = theSideGroup(s.SideID);
              sq = parseInt($scope.$selectedSides[s.SideID]);
              if (sg !== false) {
                if (possibles[sg].max === possibles[sg].qty) {
                  purchases.push({
                    SideID: s.SideID,
                    qty: sq,
                    price: s.SidePrice
                  });
                  s.buy = sq;
                } else if (possibles[sg].max < sq + possibles[sg].qty) {
                  ex = (sq + possibles[sg].qty) - possibles[sg].max;
                  s.buy = ex;
                  free.push({
                    SideID: s.SideID,
                    qty: sq - ex
                  });
                  possibles[sg].qty = possibles[sg].max;
                  purchases.push({
                    SideID: s.SideID,
                    qty: ex,
                    price: s.SidePrice
                  });
                } else {
                  free.push({
                    SideID: s.SideID,
                    qty: sq
                  });
                  possibles[sg].qty += sq;
                }
              }
            }
          }
          total = 0;
          $scope.$line.sideBuy = {
            free: free,
            purchased: purchases
          };
          for (_k = 0, _len2 = purchases.length; _k < _len2; _k++) {
            x = purchases[_k];
            total += x.qty * x.price;
          }
          return total;
        };
        $scope.calcPrice = function(x) {
          if ($specialty.specialty) {
            return x.SpecialtyBasePrice + (x.StyleSurcharge || 0);
          } else {
            return x.StandardBasePrice + (x.StyleSurcharge || 0);
          }
        };
        $scope.styleSurcharge = function() {
          var x, _i, _len, _ref;
          _ref = $scope.$sp.sizes;
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            x = _ref[_i];
            if ($scope.$line.SizeID === x.SizeID && x.StyleSurcharge > 0) {
              return x.StyleSurcharge;
            }
          }
          return 0;
        };
        verifySelectedSize = function(sizes) {
          var sel, x, _i, _len;
          if (!sizes.length) {
            return false;
          }
          sel = false;
          for (_i = 0, _len = sizes.length; _i < _len; _i++) {
            x = sizes[_i];
            if (x.SizeID === $scope.$line.SizeID) {
              sel = true;
            }
          }
          if (sel === false) {
            return $scope.$line.SizeID = sizes[0].SizeID;
          }
        };
        $scope.filterCheese = function(i) {
          if ([10, 12, 13, 49, 52, 53, 59, 60, 84, 104].indexOf(i.ItemID) !== -1) {
            return true;
          }
          return false;
        };
        $scope.filterMeat = function(i) {
          if ([10, 12, 13, 49, 52, 53, 59, 60, 84, 104].indexOf(i.ItemID) !== -1) {
            return false;
          }
          if ($scope.onMeat && [11, 14, 19, 21, 27, 28, 33, 35, 43, 44, 45, 46, 50, 51, 55, 56, 97, 105].indexOf(i.ItemID) !== -1) {
            return true;
          }
          if (!$scope.onMeat && [11, 14, 19, 21, 27, 28, 33, 35, 43, 44, 45, 46, 50, 51, 55, 56, 97, 105].indexOf(i.ItemID) === -1) {
            return true;
          }
          return false;
        };
        $scope.orderItem = function() {
          var URL, deliveryMode, json, mode, orderItemJson, orderJson, toppingsJson, x, _i, _len, _ref;
          $scope.__orderingItem = true;
          orderItemJson = {
            pUnitID: $stateParams.unitId,
            pSpecialtyID: $stateParams.specialtyId,
            pSizeID: $scope.$line.SizeID,
            pStyleID: $scope.$line.StyleID,
            pHalf1SauceID: $scope.$line.SauceID,
            pHalf2SauceID: $scope.$line.SauceID,
            pHalf1SauceModifierID: $scope.$line.SauceModifierID,
            pHalf2SauceModifierID: $scope.$line.SauceModifierID,
            pOrderLineNotes: $scope.$line.Note,
            pQuantity: $scope.$line.Quantity || 1
          };
          mode = 2;
          deliveryMode = mode === "Delivery" ? "1" : "2";
          orderJson = {
            pCustomerID: "6063",
            pCustomerName: "Vito''s Fan",
            pCustomerPhone: "1111111111",
            pAddressID: "1",
            pOrderTypeID: deliveryMode,
            pOrderNotes: ""
          };
          toppingsJson = [];
          _ref = $scope.$line.Toppings;
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            x = _ref[_i];
            toppingsJson.push({
              id: x['ItemID'],
              portion: x['Portion']
            });
          }
          json = {
            order: orderJson,
            orderItem: orderItemJson,
            orderItemToppings: toppingsJson,
            orderItemToppers: $scope.$line.Toppers,
            orderItemSides: $scope.$line.Sides,
            orderItemSidesClean: $scope.$line.sideBuy
          };
          URL = "/api/order";
          return $.ajax({
            url: URL,
            type: "PUT",
            data: JSON.stringify(json),
            success: function(data) {
              console.log(data);
              $scope.__orderingItem = false;
              $scope.$root.updateOrder();
              $scope.$apply();
              return $state.go("home");
            }
          });
        };
        $scope.setSide = function(side, value) {
          var $v;
          $scope.$selectedSides[side.SideID] = value;
          $v = {
            already: false,
            remove: false
          };
          _.each($scope.$line.Sides, function(val, key) {
            if (val.SideID === side.SideID) {
              if (value === false) {
                $v.remove = key;
              } else {
                val.Quantity = parseInt(value);
              }
              return $v.already = true;
            }
          });
          if ($v.remove !== false) {
            $scope.$line.Sides.splice($v.remove, 1);
            console.log('removed');
          }
          if (!$v.already) {
            return $scope.$line.Sides.push({
              SideID: side.SideID,
              Quantity: parseInt(value)
            });
          }
        };
        $scope.setTopping = function(topping, value, side) {
          var $v;
          if (value) {
            $scope.$selectedToppings[topping.ItemID] = side;
          } else {
            $scope.$selectedToppings[topping.ItemID] = false;
          }
          $v = {
            already: false,
            remove: false
          };
          _.each($scope.$line.Toppings, function(val, key) {
            if (val.ItemID === topping.ItemID) {
              if (value === false) {
                $v.remove = key;
              }
              val.Portion = side;
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
              Portion: side
            });
          }
        };
        $scope.setTopper = function(topper, value) {
          var exists;
          $scope.$selectedToppers[topper.TopperID] = value && true || false;
          exists = $scope.$line.Toppers.indexOf(topper.TopperID) !== -1;
          if (!value && exists) {
            $scope.$line.Toppers.splice($scope.$line.Toppers.indexOf(topper.TopperID), 1);
          }
          if (value && !exists) {
            return $scope.$line.Toppers.push(topper.TopperID);
          }
        };
        if (_.isArray($scope.$sp.specialtyDefaults)) {
          _ref = $scope.$sp.specialtyDefaults;
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            x = _ref[_i];
            $scope.setTopping(x, true, 'whole');
          }
        }
        if (!$specialty.NoBaseCheese) {
          _ref1 = $specialty.toppings;
          for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
            x = _ref1[_j];
            if (x.IsBaseCheese) {
              $scope.setTopping(x, true, 'whole');
            }
          }
        }
        $scope.$watch("$line.StyleID", function(v) {
          if (v) {
            $scope.checkingSizes = true;
            return Restangular.all("item-sizes").getList({
              "UnitID": $stateParams.unitId,
              "SpecialtyID": $stateParams.specialtyId,
              "StyleID": v
            }).then(function(v) {
              $scope.checkingSizes = false;
              verifySelectedSize(v);
              return $scope.$sp.sizes = v;
            });
          }
        });
        return $scope.$watch("$line.SizeID", function(v) {
          if (v) {
            return Restangular.all("item-sides").getList({
              "UnitID": $stateParams.unitId,
              "SizeID": v
            }).then(function(v) {
              return $scope.$sp.defaultSideGroups = v;
            });
          }
        });
      }
    });
  });

  $app.run(function($state, $rootScope, Restangular) {
    var $scope, updateSubtotal, updateTotal;
    $scope = $rootScope;
    $scope.$order = {};
    $scope.$lines = [];
    $scope.$promoCode = "";
    $scope.__loadingOrder = true;
    window.__itemDetail = function(unitId, specialtyId) {
      return $state.go('detail', {
        unitId: unitId,
        specialtyId: specialtyId
      });
    };
    window.updateOrder = function() {
      return $scope.updateOrder();
    };
    $scope.$applyPromo = function() {
      if ($scope.$promoCode.length > 1) {
        return $scope.$order.customPOST({
          CouponCode: $scope.$promoCode
        }, 'add-promo').then(function() {
          return $scope.updateOrder();
        });
      }
    };
    $scope.deleteLineItem = function($line) {
      var $cl, $i, _i, _len, _ref;
      _ref = $scope.$lines;
      for ($i = _i = 0, _len = _ref.length; _i < _len; $i = ++_i) {
        $cl = _ref[$i];
        if ($cl.OrderLineID === $line.OrderLineID) {
          $scope.$lines.splice($i, 1);
          break;
        }
      }
      $line.remove().then(function() {
        $scope.__loadingOrder = true;
        return Restangular.one("order").get().then(function($order) {
          $scope.$order = $order;
          return $scope.__loadingOrder = false;
        });
      });
      return updateSubtotal($scope.$lines);
    };
    $scope.adjustUnitName = function(d) {
      if (d.unit.UnitID === 15) {
        return d.size.SizeDescription + ' ' + d.style.StyleDescription;
      }
      if (d.unit.UnitID === 7) {
        return d.size.SizeDescription + ' ' + d.unit.UnitDescription;
      }
      if (d.specialty != null) {
        return d.specialty.SpecialtyShortDescription + ' ' + d.unit.UnitDescription;
      }
      if (d.unit.UnitID === 1) {
        return "Build your Own Pizza";
      }
      return d.unit.UnitDescription;
    };
    $scope.sizePretty = function(size) {
      var i, out, words, _i, _len;
      if (size == null) {
        return '•';
      }
      out = "";
      if (size.indexOf(' ') !== -1) {
        words = size.split(' ');
        if (/^[0-9]+$/.test(words.slice(-1)[0])) {
          return words.slice(-1)[0];
        }
        for (_i = 0, _len = words.length; _i < _len; _i++) {
          i = words[_i];
          out += i.substr(0, 1);
        }
        return out;
      }
      out = size.substr(0, 2);
      if (out.toLowerCase() === 'me') {
        return 'MD';
      }
      return out;
    };
    $scope.showSubmit = function() {
      if (window.location.pathname === '/order' || window.location.pathname === '/locations') {
        return true;
      }
      return false;
    };
    $scope.halfPretty = function(half) {
      var halfs;
      half = parseInt(half);
      halfs = ['Whole', 'Left', 'Right', '2x'];
      return halfs[half];
    };
    $scope.updateOrder = function() {
      $scope.__loadingOrder = true;
      $scope.$appliedCoupons = Restangular.all('applied-coupons').getList().$object;
      return Restangular.one("order").get().then(function($order) {
        $scope.$order = $order;
        if (!angular.isFunction($order.getList)) {
          $scope.__loadingOrder = false;
          return;
        }
        return $order.getList('lines').then(function($items) {
          $scope.$lines = $items;
          updateSubtotal($scope.$lines);
          return $scope.__loadingOrder = false;
        })["catch"](function() {
          $scope.__loadingError = true;
          return $scope.__loadingOrder = false;
        });
      })["catch"](function() {
        $scope.__loadingError = true;
        return $scope.__loadingOrder = false;
      });
    };
    updateSubtotal = function($items) {
      var item, total, _i, _len;
      if ($items.length > 0) {
        total = 0;
        for (_i = 0, _len = $items.length; _i < _len; _i++) {
          item = $items[_i];
          total += item.Quantity * (item.Cost - item.Discount);
        }
        return $scope.$orderSubtotal = total;
      }
    };
    $scope.$orderTotal = 0;
    updateTotal = function(v) {
      if (($scope.$orderSubtotal != null) && $scope.$orderSubtotal > 0) {
        return $scope.$orderTotal = $scope.$orderSubtotal + $scope.$order.Tax + $scope.$order.Tax2 + parseInt($scope.$order.Tip === '' ? 0 : $scope.$order.Tip) + $scope.$order.DeliveryCharge;
      }
    };
    $scope.$watch("$orderSubtotal", updateTotal);
    $scope.$watch("$order.Tip", updateTotal);
    $scope.$watch("$order.Tip", function(v, o) {
      if (o != null) {
        return $scope.$order.customPOST({
          tip: v
        }, 'update-tip');
      }
    });
    $scope.updateOrder();
  });

}).call(this);
