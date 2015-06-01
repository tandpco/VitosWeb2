(function() {
  var $app;

  $app = angular.module('app', ['ngRoute', 'ui.router', 'restangular']);

  (function(con) {
    "use strict";
    var dummy, empty, method, methods, prop, properties;
    prop = void 0;
    method = void 0;
    empty = {};
    dummy = function() {};
    properties = "memory".split(",");
    methods = ("assert,clear,count,debug,dir,dirxml,error,exception,group," + "groupCollapsed,groupEnd,info,log,markTimeline,profile,profiles,profileEnd," + "show,table,time,timeEnd,timeline,timelineEnd,timeStamp,trace,warn").split(",");
    while (prop = properties.pop()) {
      con[prop] = con[prop] || empty;
    }
    while (method = methods.pop()) {
      con[method] = con[method] || dummy;
    }
  })(this.console = this.console || {});

  $app.config(function($stateProvider, $urlRouterProvider, RestangularProvider) {
    RestangularProvider.setBaseUrl('/api');
    RestangularProvider.setFullRequestInterceptor(function(element, operation, what, url, headers, params) {
      return {
        headers: headers,
        params: _.extend(params, {
          cacheKilla: new Date().getTime()
        }),
        element: element
      };
    });
    $urlRouterProvider.otherwise("/");
    return $stateProvider.state('home', {
      url: '/',
      template: '<div></div>',
      controller: function() {}
    }).state('detail', {
      url: "/detail/:unitId/:specialtyId?coupon",
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
        var $UnitID, $coupon, $to, freeColors, theSideGroup, verifySelectedSize, x, _i, _j, _len, _len1, _ref, _ref1;
        $scope.$sp = $specialty;
        $scope.onMeat = true;
        $scope.__orderingItem = false;
        $scope.tab = 'size';
        $scope.$line = {
          SauceID: $specialty.specialty && $specialty.specialty.SauceID || null,
          SizeID: 9,
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
        console.log($scope);
        $UnitID = parseInt($stateParams.unitId);
        if ($UnitID === 1 && !$stateParams.specialtyId) {
          $scope.$line.SauceID = 6;
        }
        $scope.$line.UnitID = $UnitID;
        if ($specialty.styles.length === 0 && $specialty.sizes.length > 0) {
          $scope.$line.SizeID = $specialty.sizes[0].SizeID;
        }
        if ($specialty.styles.length > 0 && !$scope.$line.StyleID) {
          $scope.$line.StyleID = $specialty.styles[0].StyleID;
        }
        if ($stateParams.coupon) {
          $coupon = $scope.$root.getCoupon($stateParams.coupon);
          $scope.$coupon = $coupon;
          if ($coupon) {
            $to = $coupon.AppliesTo[0];
            if ($to.StyleID) {
              $scope.$line.StyleID = $to.StyleID;
            }
            if ($to.SizeID) {
              $scope.$line.SizeID = $to.SizeID;
            }
          }
          console.log($coupon);
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
          var s, sQuantity, sg, _i, _j, _len, _len1, _ref, _ref1;
          _ref = $scope.$sp.defaultSideGroups;
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            sg = _ref[_i];
            if (parseInt($scope.$line.Quantity) > 1) {
              sQuantity = sg.Quantity * $scope.$line.Quantity;
            } else {
              sQuantity = sg.Quantity;
            }
            _ref1 = sg.sides;
            for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
              s = _ref1[_j];
              if (s.SideID === $side.SideID) {
                return sg.sides.length === 1 && 1 || 'any ' + sQuantity;
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
          var ex, free, i, possibles, purchases, s, sQuantity, sg, sides, sq, total, x, _i, _j, _k, _len, _len1, _len2, _ref;
          sides = $scope.$sp.extraSides;
          possibles = [];
          _ref = $scope.$sp.defaultSideGroups;
          for (i = _i = 0, _len = _ref.length; _i < _len; i = ++_i) {
            x = _ref[i];
            if (parseInt($scope.$line.Quantity) > 1) {
              sQuantity = x.Quantity * $scope.$line.Quantity;
            } else {
              sQuantity = x.Quantity;
            }
            possibles[i] = {
              qty: 0,
              max: sQuantity
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
              } else {
                purchases.push({
                  SideID: s.SideID,
                  qty: sq,
                  price: s.SidePrice
                });
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
          var $out;
          if (!x) {
            return 0;
          }
          if ($specialty.specialty) {
            $out = x.SpecialtyBasePrice + (x.StyleSurcharge || 0);
          } else {
            $out = x.StandardBasePrice + (x.StyleSurcharge || 0);
          }
          return $out;
        };
        $scope.couponPrice = function(x) {
          var $for, $out, $price, size, _i, _j, _len, _len1, _ref, _ref1;
          if (x == null) {
            _ref = $scope.$sp.sizes;
            for (_i = 0, _len = _ref.length; _i < _len; _i++) {
              size = _ref[_i];
              if (size.SizeID === $scope.$line.SizeID) {
                x = size;
                break;
              }
            }
          }
          $price = $scope.calcPrice(x);
          $coupon = $scope.$coupon;
          if (!$coupon) {
            return null;
          }
          if (x.SizeID) {
            _ref1 = $coupon.AppliesTo;
            for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
              $for = _ref1[_j];
              if ($for.SizeID === x.SizeID && $for.UnitID === x.UnitID) {
                if ($for.FixedPrice) {
                  $out = $for.FixedPrice;
                }
                if ($for.DollarOff) {
                  $out = $price - $for.DollarOff;
                }
                if (x.SpecialtyID) {
                  $out += $for.AddForSpecialty;
                }
                return $out;
              }
            }
          }
          return null;
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
          if ($scope.__orderingItem === true) {
            return;
          }
          if ($scope.$parent.$lines.length >= 15) {
            return alert("You can only add 15 items to your order.");
          }
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
            $scope.setTopping(x, true, x.SpecialtyItemQuantity === 2 && '2x' || 'whole');
          }
        }
        if (!$specialty.NoBaseCheese) {
          _ref1 = $specialty.toppings;
          for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
            x = _ref1[_j];
            if (x.IsBaseCheese) {
              $scope.setTopping(x, true, x.SpecialtyItemQuantity === 2 && '2x' || 'whole');
            }
          }
        }
        $scope.sideByDefault = [];
        $scope.$watchCollection("$sp.defaultSideGroups", function(v) {
          var r, y, _k, _l, _len2, _len3, _ref2, _results;
          _ref2 = $scope.sideByDefault;
          for (_k = 0, _len2 = _ref2.length; _k < _len2; _k++) {
            y = _ref2[_k];
            $scope.setSide(y, '0');
          }
          $scope.sideByDefault = [];
          if ((v != null) && _.isArray(v)) {
            _results = [];
            for (_l = 0, _len3 = v.length; _l < _len3; _l++) {
              x = v[_l];
              if (_.isArray(x.sides)) {
                _results.push((function() {
                  var _len4, _m, _ref3, _results1;
                  _ref3 = x.sides;
                  _results1 = [];
                  for (_m = 0, _len4 = _ref3.length; _m < _len4; _m++) {
                    r = _ref3[_m];
                    if (r.IsDefault) {
                      $scope.sideByDefault.push(r);
                      _results1.push($scope.setSide(r, '1'));
                    } else {
                      _results1.push(void 0);
                    }
                  }
                  return _results1;
                })());
              } else {
                _results.push(void 0);
              }
            }
            return _results;
          }
        });
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
      var key, value, _i, _len, _ref;
      _ref = $scope.$lines;
      for (value = _i = 0, _len = _ref.length; _i < _len; value = ++_i) {
        key = _ref[value];
        if (key.OrderLineID === $line.OrderLineID) {
          $scope.$lines.splice(value, 1);
          console.log(key, value);
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
      console.log('SCOPELINE', $scope.$lines);
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
    $scope.getCoupon = function(id) {
      var $coupon, _i, _len, _ref;
      _ref = $scope.$appliedCoupons;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        $coupon = _ref[_i];
        if ($coupon.CouponID === parseInt(id)) {
          return $coupon;
        }
      }
      return null;
    };
    $scope.showSubmit = function() {
      if (window.location.pathname === '/order' || window.location.pathname === '/locations' || window.location.pathname === '/deals') {
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
      $scope.$appliedCoupons = [];
      Restangular.all('applied-coupons').getList().then(function(v) {
        return $scope.$appliedCoupons = v;
      });
      return Restangular.one("order").get().then(function($order) {
        var $coupon, $to;
        $scope.$order = $order;
        if (!angular.isFunction($order.getList)) {
          $scope.__loadingOrder = false;
          if ($scope.$appliedCoupons.length) {
            $coupon = $scope.$appliedCoupons[0];
            $to = $coupon.AppliesTo[0];
            $state.go('detail', {
              unitId: $to.UnitID,
              specialtyId: $to.SpecialtyID,
              coupon: $coupon.CouponID
            });
          }
          return;
        }
        return $order.getList('lines').then(function($items) {
          $scope.$lines = $items;
          updateSubtotal($scope.$lines);
          return $scope.__loadingOrder = false;
        }, function() {
          $scope.__loadingError = true;
          return $scope.__loadingOrder = false;
        });
      }, function() {
        $scope.__loadingError = true;
        return $scope.__loadingOrder = false;
      });
    };
    updateSubtotal = function($items) {
      var item, total, _i, _len;
      if ($items.length >= 0) {
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
