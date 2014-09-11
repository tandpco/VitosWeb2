function Session () {}
var $__localCache = {}
Session.createSession = function() {
    var json = { 
    }

    var returnValue = "";
    $.ajax({
        url: "/rest/view/session/create-session",
        type: "POST",
        data: JSON.stringify(json),
        success: function(data) {
            console.log(data);
            if(data != '' && data != null) {
                sessionId = data["sessionId"];
                $.session.set('sessionId', sessionId);
                returnValue = sessionId;
            }
        },
        async:   false
    });

    return(returnValue);
}
Session.get = function(name) {
    var sessionId = $.session.get('sessionId');
    var json = {
        sessionId: sessionId,
        key: name
    }

    // if a value is already available, we know we've already fetched or set this var. no need to re-get it
    if(typeof $__localCache[name] != 'undefined') {
        return $__localCache[name];
    }

    var returnValue = "";
    $.ajax({
        url: "/rest/view/session/get",
        type: "POST",
        data: JSON.stringify(json),
        success: function(data) {
            console.log(data);
            if(data != '' && data != null) {
                returnValue = data
            }
        },
        async:   false
    });
    return $__localCache[name] = returnValue
}
Session.set = function(name, value) {
    if(typeof $__localCache[name] != 'undefined' && ($__localCache[name] === JSON.stringify(value) || $__localCache[name] === value)) {
        return $__localCache[name];
    }

    var sessionId = $.session.get('sessionId');

    var json = {
        sessionId: sessionId,
        key: name,
        value: value
    }

    var returnValue = {};
    $.ajax({
        url: "/rest/view/session/set",
        type: "POST",
        data: JSON.stringify(json),
        success: function(data) {
            console.log(data);
            if(data != '' && data != null) {
                returnValue = data
            }
        },
        async:   false
    });
    if(typeof value == 'object')
        $__localCache[name] = JSON.stringify(value)
    else
        $__localCache[name] = value
    return(returnValue);

}
Session.clear = function() {
    Session.createSession();
}


function NavBar () {}
NavBar.createMarkup = function() {
    var html = "";
    html += '<nav class="navbar-default main-navbar" role="navigation">';
    html += '    <div class="container">';
    html += '        <!-- Brand and toggle get grouped for better mobile display -->';
    html += '        <div class="navbar-header">';
    html += '            <button type="button" class="navbar-toggle" data-toggle="collapse" data-target=".navbar-collapse" id="collapse-button">';
    html += '                <span class="sr-only">Toggle navigation</span>';
    html += '                <span class="icon-bar"></span>';
    html += '                <span class="icon-bar"></span>';
    html += '                <span class="icon-bar"></span>';
    html += '            </button>';
    html += '        </div>';
    html += '';
    html += '        <!-- Collect the nav links, forms, and other content for toggling -->';
    html += '        <div class="collapse navbar-collapse">';
    html += '            <ul class="nav navbar-nav navbar-right">';
     var curr_loc= window.location.pathname;
    html += '                <li><a href="/order-pizza" class="white-shadow'+(true ? ' active':'')+'">MENU</a></li>';
    html += '                <li><a href="/order-subs" class="white-shadow"'+(curr_loc.indexOf("deals")!=-1?'style="background-color:#006122"':'')+'>DEALS</a></li>';
    html += '                <li><a href="/order-salads" class="white-shadow"'+(curr_loc.indexOf("locations")!=-1?'style="background-color:#006122"':'')+'>LOCATIONS</a></li>';
    // html += '                <li><a href="/order-sides" class="white-shadow"'+(curr_loc.indexOf("sides")!=-1?'style="background-color:#006122"':'')+'>SIDES</a></li>';
    // html += '                <li><a href="/sign-in" onclick="Session.clear()" class="white-shadow">Sign Out</a></li>';
    // html += '                <li><a href="/order-pizza" class="white-shadow"'+(curr_loc.indexOf("pizza")!=-1?'style="background-color:#006122"':'')+'>PIZZAS</a></li>';
    // html += '                <li><a href="/order-subs" class="white-shadow"'+(curr_loc.indexOf("subs")!=-1?'style="background-color:#006122"':'')+'>SUBS</a></li>';
    // html += '                <li><a href="/order-salads" class="white-shadow"'+(curr_loc.indexOf("salads")!=-1?'style="background-color:#006122"':'')+'>SALADS</a></li>';
    // html += '                <li><a href="/order-sides" class="white-shadow"'+(curr_loc.indexOf("sides")!=-1?'style="background-color:#006122"':'')+'>SIDES</a></li>';
    // html += '                <li><a href="/sign-in" onclick="Session.clear()" class="white-shadow">Sign Out</a></li>';
    html += '            </ul>';
    html += '        </div>';
    html += '    </div>';
    html += '</nav>';
    html += '<nav class="navbar-default sub-navbar" role="navigation">';
    html += '    <div class="container">';
    html += '';
    html += '        <!-- Collect the nav links, forms, and other content for toggling -->';
    html += '        <div class="collapse navbar-collapse">';
    html += '            <ul class="nav navbar-nav navbar-right">';
     var curr_loc= window.location.pathname;
    html += '                <li><a href="/order-pizza" class="white-no-shadow'+(curr_loc.indexOf("pizza")!=-1 ? ' active':'')+'">PIZZAS</a></li>';
    html += '                <li><a href="/order-subs" class="white-no-shadow'+(curr_loc.indexOf("subs")!=-1 ? ' active':'')+'">SUBS</a></li>';
    html += '                <li><a href="/order-salads" class="white-no-shadow'+(curr_loc.indexOf("salads")!=-1 ? ' active':'')+'">SALADS</a></li>';
    html += '                <li><a href="/order-sides" class="white-no-shadow'+(curr_loc.indexOf("sides")!=-1 ? ' active':'')+'">SIDES</a></li>';
    html += '            </ul>';
    html += '        </div>';
    html += '    </div>';
    html += '</nav>';
    return html;
}

function ModalPleaseWait () {}
ModalPleaseWait.createMarkup = function(name, message) {
    var html = "";
    html += '<div class="modal fade" data-backdrop="static" data-keyboard="false" id="' + name + '">';
    html += '    <div class="modal-dialog">';
    html += '        <div class="modal-content">';
    html += '            <div class="modal-body">';
    html += '                <h4 class="modal-title">' + message + '</h4>';
    html += '                <img src="/img/loading.gif"></img>';
    html += '            </div>';
    html += '        </div><!-- /.modal-content -->';
    html += '    </div><!-- /.modal-dialog -->';
    html += '</div><!-- /.modal -->';
    return html;
}

function ModalDelivery () {}
ModalDelivery.createMarkup = function(name, message, isRedirect) {
    var html = "";
    html += '<div class="modal fade" data-backdrop="static" data-keyboard="false" id="' + name + '">';
    html += '    <div class="modal-dialog">';
    html += '        <div class="modal-content">';
    html += '            <div class="modal-body">';

    html += '                <h5 class="modal-title">' + message + '</h4>';
    html += '                <a style="cursor:pointer; cursor:hand;" id="modeDelivery" onclick="CommonUtils.chooseDelivery(\''+isRedirect+'\')">';
    html += '                    <img src="/img/mode-delivery.png"/>';
    html += '                </a>';

    html += '                <a style="cursor:pointer; cursor:hand;" id="modePickup" onclick="CommonUtils.choosePickup(\''+isRedirect+'\')">';
    html += '                    <img src="/img/mode-pickup.png"/>';
    html += '                </a>';
    html += '            </div>';
    html += '        </div><!-- /.modal-content -->';
    html += '    </div><!-- /.modal-dialog -->';
    html += '</div><!-- /.modal -->';
    return html;
}

function ModalStoreIsClosed () {}
ModalStoreIsClosed.createMarkup = function(name, message) {
    var html = "";
    html += '<div class="modal fade" data-backdrop="static" data-keyboard="false" id="' + name + '">';
    html += '    <div class="modal-dialog">';
    html += '        <div class="modal-content">';
    html += '            <div class="modal-body">';
    html += '                <div class="row">';
    html += '                    <h4 class="modal-title">Store is currently closed.<br>Please try again during normal business hours.</h4>';
    html += '                </div>';
    html += '                <div class="row">';
    html += '                    <button class="red-gradient-button" onclick="Session.clear(); window.location.href = \'/sign-in\';">' + message + '</button>';
    html += '                </div>';
    html += '            </div>';
    html += '        </div><!-- /.modal-content -->';
    html += '    </div><!-- /.modal-dialog -->';
    html += '</div><!-- /.modal -->';
    return html;
}


function ModalInvalidLogin () {}
ModalInvalidLogin.createMarkup = function(name, message) {
    var html = "";
    html += '<div class="modal fade" data-backdrop="static" data-keyboard="false" id="' + name + '">';
    html += '    <div class="modal-dialog">';
    html += '        <div class="modal-content">';
    html += '            <div class="modal-body">';
    html += '                <div class="row">';
    html += '                    <h4 class="modal-title">Invalid e-mail address or password.</h4>';
    html += '                </div>';
    html += '                <div class="row">';
    html += '                    <button class="red-gradient-button" onclick="$(\'#modal-invalid-login\').modal(\'hide\');">' + message + '</button>';
    html += '                </div>';
    html += '            </div>';
    html += '        </div><!-- /.modal-content -->';
    html += '    </div><!-- /.modal-dialog -->';
    html += '</div><!-- /.modal -->';
    return html;
}


function ModalInvalidPromo () {}
ModalInvalidPromo.createMarkup = function(name, message) {
    var html = "";
    html += '<div id="' + name + '" class="modal fade" data-backdrop="static" data-keyboard="false">';
    html += '    <div class="modal-dialog" style="width:25%">';
    html += '        <div class="modal-content">';
    html += '            <div class="modal-body">';
    html += '                <div class="row">';
    html += '                    <h4 class="modal-title">' + message + '</h4><br>';
    html += '                </div>';
    html += '                <div class="row">';
    html += '                    <button class="red-gradient-button" onclick="$(\'#modal-invalid-promo\').modal(\'hide\');" style="width:30%">Ok</button>';
    html += '                </div>';
    html += '            </div>';
    html += '        </div><!-- /.modal-content -->';
    html += '    </div><!-- /.modal-dialog -->';
    html += '</div><!-- /.modal -->';
    return html;
}

function ModalLocation () {}
ModalLocation.createMarkup = function(name, message) {
    var html = "";
    html += '<div class="modal fade" data-backdrop="static" data-keyboard="false" id="' + name + '">';
    html += '    <div class="modal-dialog">';
    html += '        <div class="modal-content">';
    html += '            <div class="modal-body">';
    html += '                <div class="row">';
    html += '                    <h4 class="modal-title">' + message + '</h4>';
    html += '                </div>';
    html += '                <div class="row">';
    html += '                    <div id="storeInfo">';
    html += '                    </div>';
    html += '                </div>';
    html += '                <div class="row">';
    html += '                    <button class="red-gradient-button" onclick="CommonUtils.chooseStore()">CHANGE LOCATION</button>';
    html += '                </div>';
    html += '                <div class="row">';
    html += '                    <button class="green-gradient-button" onclick="CommonUtils.chooseMode()">CONTINUE</button>';
    html += '                </div>';
    html += '            </div>';
    html += '        </div><!-- /.modal-content -->';
    html += '    </div><!-- /.modal-dialog -->';
    html += '</div><!-- /.modal -->';
    return html;
}

function ModalStores () {}
ModalStores.createMarkup = function(name, message) {
    var html = "";
    html += '<div class="modal fade" data-backdrop="static" data-keyboard="false" id="' + name + '">';
    html += '    <div class="modal-dialog">';
    html += '        <div class="modal-content">';
    html += '            <div class="modal-body">';
    html += '                <div class="row">';
    html += '                    <h4 class="modal-title">' + message + '</h4>';
    html += '                </div>';
    html += '                <div class="row">';
    html += '                    <div id="stores">';
    html += '                    </div>';
    html += '                </div>';
    html += '            </div>';
    html += '        </div><!-- /.modal-content -->';
    html += '    </div><!-- /.modal-dialog -->';
    html += '</div><!-- /.modal -->';
    return html;
}

function CommonUtils() {}
CommonUtils.chooseDelivery = function(isRedirect) {
    Session.set('mode', 'Delivery');
    $('#modal-delivery').modal('hide');
    $('.modal-backdrop').remove();
    if(isRedirect =="YES"){
       window.location.href = "/order-pizza";
    }
    else if(isRedirect =="NO"){
       OrderItems.buildYourOrder();
    }
}

CommonUtils.choosePickup = function(isRedirect) {
    Session.set('mode', 'Pickup');
    $('#modal-delivery').modal('hide');
    $('.modal-backdrop').remove();
    if(isRedirect =="YES"){
       window.location.href = "/order-pizza";
    }
    else if(isRedirect =="NO"){
       OrderItems.buildYourOrder();
    }
}

CommonUtils.chooseMode = function() {
    $('#modal-location').modal('hide');
    if(Session.get('deliveryAvailable') == "true") {
        $('#modal-delivery').modal('show');
    }
    else {
        CommonUtils.choosePickup('YES');
    }
}


CommonUtils.chooseLocation = function(storeId) {
    var json = {
        storeId:      storeId,
        streetName:   Session.get("streetName"),
        streetNumber: Session.get("streetNumber"),
        zip: Session.get("zip")
    }

    $.ajax({
        url: "/rest/view/store/get-store",
        type: "POST",
        data: JSON.stringify(json),
        success: function(data) {
            // Yay! It worked!
            if(data != '') {
                var store = data[0]
                storeId          = store['StoreID'];
                storeName        = store['StoreName'];
                addressLine1     = store['Address1'];
                addressLine2     = store['ADdress2'];
                city             = store['City'];
                state            = store['State'];
                postalCode       = store['PostalCode'];
                phone            = store['Phone']
                hours            = store['Hours'];
                isOpen           = store['IsOpen'];
                driverMoney      = store['DefaultDriverMoney'];
                deliveryCharge   = store['DefaultDeliveryCharge'];
                deliveryMin      = store['DeliveryMin'];

                Session.set('driverMoney', driverMoney);
                Session.set('deliveryCharge', deliveryCharge);
                Session.set('deliveryMin', deliveryMin);

                //console.log(hours);
                //console.log('Store is open: ' + isOpen);

                if(isOpen == false) {
                    $('#modal-store-is-closed').modal('show');
                }

                Session.set('storeId', storeId);

                var storeAddress = addressLine1 + ' ' + city + ', ' + state + ', ' + postalCode;
                Session.set('storeAddress', storeAddress);

                /*
                array = phone.split('');
                if(array.length > 0) {
                    phone = "(" + array[0] + array[1] + array[2] + ") " + array[3] + array[4] + array[5] + "-" + array[6] + array[7] + array[8]+ array[9];
                }
                */

                html  = '<img src="/img/store-' + storeId + '-map.png"></img>';
                html += '<h5>' + addressLine1 + '</h5>';
                html += '<h5>' + city + ", " + state + " " + postalCode + '</h5>';
                html += '<label for="#store_phone_num">' + 'PHONE: </label><p id="store_phone_num">' + phone + '</p>';
                html += '<label>' + "HOURS" + '</label>';
                html += '<p>' + hours + '</p>';
                $('#storeInfo').html(html);

                $('#storeInfo').find("img").css({height: "200px", width: "200px"});
                $('#storeInfo').attr("align","center");

                $('#modal-please-wait').modal('hide');
                $('#modal-location').modal('show');
            }
            else {
                $('#modal-please-wait').modal('hide');
                $('#modal-invalid-login').modal('show');
            }
        }
    });
}

CommonUtils.chooseStore = function() {
    var json = {
    }

    $.ajax({
        url: "/rest/view/store/list-stores",
        type: "POST",
        data: JSON.stringify(json),
        success: function(data) {
            // Yay! It worked!
            if(data != '') {
                var stores = data;
                var html   = "<h3>Stores:</h3>";

                $.each(data, function( index ) {
                    store = data[index];
                    console.log(store);

                    storeId          = store['StoreID'];
                    storeName        = store['StoreName'];
                    addressLine1     = store['Address1'];
                    addressLine2     = store['ADdress2'];
                    city             = store['City'];
                    state            = store['State'];
                    postalCode       = store['PostalCode'];
                    phone            = store['Phone']
                    hours            = store['Hours'];

                    var storeAddress = addressLine1 + ' ' + city + ', ' + state + ', ' + postalCode; 
                    var search       = addressLine1 + ' ' + postalCode; 
                    html += "<div>"
                    html += '<a href="#" onclick="$(\'#modal-stores\').modal(\'hide\'); CommonUtils.findStore(\'' + search + '\', false);">' + storeAddress + '</a>'
                    html += "</div>"
                });
                $('#stores').html(html);

                $('#modal-please-wait').modal('hide');
                $('#modal-stores').modal('show');
            }
            else {
                $('#modal-please-wait').modal('hide');
                $('#modal-invalid-login').modal('show');
            }
        }
    });
}

CommonUtils.findStore = function(search, isCustomerAddress) {
    $('#modal-please-wait').modal();
    geo.geocode({address:search}, function (results,status) { 
        // If that was successful
        if (status == google.maps.GeocoderStatus.OK) {
            // Lets assume that the first marker is the one we want
            var point = results[0];
            var location = point.geometry.location;
            var lat = location.lat();
            var lng = location.lng();

            // Get Google's version of the address
            var streetNumber = "";
            var route        = "";
            var city         = "";
            var state        = "";
            var zip          = "";
            for (var component in point['address_components']) {
                var shortName = point['address_components'][component]['short_name'];
                for (var i in point['address_components'][component]['types']) {
                    var type = point['address_components'][component]['types'][i];
                    if (type == "administrative_area_level_1") {
                        state = shortName;
                    }
                    if (type == "locality") {
                        city = shortName;
                    }
                    if (type == "street_number") {
                        streetNumber = shortName;
                    }
                    if (type == "route") {
                        route = shortName;
                    }
                    if (type == "postal_code") {
                        zip = shortName;
                    }
                }
            }
            var street = streetNumber + " " + route;
            Session.set('streetName', route);
            Session.set('streetNumber', streetNumber);
            Session.set('addressLine1', street);
            Session.set('city', city);
            Session.set('state', state);
            Session.set('zip', zip);

            // Output the data
            var msg = 'address="' + search + '" lat=' +lat+ ' lng=' +lng+ '(delay=' + delay + 'ms)<br>';
            console.log("Address From Google: " + street);

            var customerX = 0.0;
            var customerY = 0.0;
            if(isCustomerAddress) {
                customerX = lng;
                customerY = lat;
                Session.set('customerX', customerX);
                Session.set('customerY', customerY);
            }
            else {
                customerX = Session.get('customerX');
                customerY = Session.get('customerY');
            }

            var json = {
                x:            lng,
                y:            lat,
                customerX:   customerX,
                customerY:   customerY,
                streetName:   route,
                streetNumber: streetNumber,
                zip:          zip
            }
    
            $.ajax({
                url: "/rest/view/store-locator/find-store",
                type: "POST",
                data: JSON.stringify(json),
                success: function(data) {
                    // Yay! It worked!
                    if(data != '') {
                        var storeId = data['StoreID']
                        //CommonUtils.chooseLocation(storeId);
                        if(data['storeInfo'] != '') {
                            var store = data['storeInfo'][0]
                            storeId          = store['StoreID'];
                            storeName        = store['StoreName'];
                            addressLine1     = store['Address1'];
                            addressLine2     = store['ADdress2'];
                            city             = store['City'];
                            state            = store['State'];
                            postalCode       = store['PostalCode'];
                            phone            = store['Phone']
                            hours            = store['Hours'];
                            isOpen           = store['IsOpen'];
                            driverMoney      = store['DefaultDriverMoney'];
                            deliveryCharge   = store['DefaultDeliveryCharge'];
                            deliveryMin      = store['DeliveryMin'];
            
                            Session.set('deliveryAvailable', data['DeliveryAvailable']);
                            Session.set('driverMoney', driverMoney);
                            Session.set('deliveryCharge', deliveryCharge);
                            Session.set('deliveryMin', deliveryMin);
            
                            //console.log(hours);
                            //console.log('Store is open: ' + isOpen);
            
                            if(isOpen == false) {
                                $('#modal-store-is-closed').modal('show');
                            }
            
                            Session.set('storeId', storeId);
            
                            var storeAddress = addressLine1 + ' ' + city + ', ' + state + ', ' + postalCode;
                            Session.set('storeAddress', storeAddress);
            
                            /*
                            array = phone.split('');
                            if(array.length > 0) {
                                phone = "(" + array[0] + array[1] + array[2] + ") " + array[3] + array[4] + array[5] + "-" + array[6] + array[7] + array[8]+ array[9];
                            }
                            */
            
                            html  = '<img src="/img/store-' + storeId + '-map.png"></img>';
                            html += '<h5>' + addressLine1 + '</h5>';
                            html += '<h5>' + city + ", " + state + " " + postalCode + '</h5>';
                            html += '<label for="#store_phone_num">' + 'PHONE: </label><p id="store_phone_num">' + phone + '</p>';
                            html += '<label>' + "HOURS" + '</label>';
                            html += '<p>' + hours + '</p>';
                            $('#storeInfo').html(html);
            
                            $('#storeInfo').find("img").css({height: "200px", width: "200px"});
                            $('#storeInfo').attr("align","center");
            
                            $('#modal-please-wait').modal('hide');
                            $('#modal-location').modal('show');
                        }
                        else {
                            $('#modal-please-wait').modal('hide');
                            $('#modal-invalid-login').modal('show');
                        }
                    }
                }
            });

        }
        // ====== Decode the error status ======
        else {
            // === if we were sending the requests to fast, try this one again and increase the delay
            if (status == google.maps.GeocoderStatus.OVER_QUERY_LIMIT) {
                delay++;
            } else {
                var reason="Code "+status;
                var msg = 'address="' + search + '" error=' + reason + '(delay=' + delay + 'ms)<br>';
            }   
        }
      }
    );
}
function ModalModifyPizzaItem() {}
ModalModifyPizzaItem.createMarkup = function () {
    var html = "";
    //html += '<div class="modal fade" id="modal-modify-item">';
    html += '    <div class="modal-dialog modal-lg">';
    html += '        <div class="modal-content">';
    html += '            <div class="modal-header">';
    html += '                <img onclick="pageController.cancel()" src=';
    html += '                "/img/closebutton.png" data-dismiss="modal"';
    html += '                aria-hidden="true">';
    html += '';
    html += '                <ul class="nav nav-tabs">';
    html += '                    <li class="active"><a class="white-no-shadow"';
    html += '                    href="#size-and-crust" data-toggle="tab">SIZE';
    html += '                    &amp; TYPE</a></li>';
    html += '';
    html += '                    <li><a class="white-no-shadow" href=';
    html += '                    "#cheese-and-sauce" data-toggle="tab">SAUCE</a></li>';
    html += '';
    html += '                    <li><a class="white-no-shadow" href="#toppings"';
    html += '                    data-toggle="tab">TOPPINGS</a></li>';
    html += '                </ul>';
    html += '            </div>';
    html += '';
    html += '            <div class="modal-body">';
    html += '                <div class="tab-content">';
    html += '                    <div class="tab-pane fade active in" id=';
    html += '                    "size-and-crust">';
    html += '                        <table>';
    html += '                            <tr>';
    html += '                                <td valign="top">';
    html += '                                    <ul class="left-column" style=';
    html += '                                    "margin:0px;padding:0px;list-style-type:none">';
    html += '                                    </ul>';
    html += '                                </td>';
    html += '';
    html += '                                <td valign="top">';
    html += '                                    <ul class="right-column" style=';
    html += '                                    "margin:0px;padding:0px;list-style-type:none;"></ul>';
    html += '                                </td>';
    html += '                            </tr>';
    html += '                        </table>';
    html += '                    </div>';
    html += '';
    html += '                    <div class="tab-pane fade" id=';
    html += '                    "cheese-and-sauce">';
    html += '                        <table>';
    html += '                            <tr>';
    html += '                                <td valign="top">';
    html += '                                    <ul class="left-column" style=';
    html += '                                    "margin:0px;padding:0px;list-style-type:none">';
    html += '                                    </ul>';
    html += '                                </td>';
    html += '';
    html += '                                <td valign="top">';
    html += '                                    <ul class="right-column" style=';
    html += '                                    "margin:0px;padding:0px;list-style-type:none;">';
    html += '                                    </ul>';
    html += '                                </td>';
    html += '                            </tr>';
    html += '                        </table>';
    html += '                    </div>';
    html += '';
    html += '                    <div class="tab-pane fade" id="toppings">';
    html += '                        <table>';
    html += '                            <tr>';
    html += '                                <td valign="top">';
    html += '                                    <ul class="left-column" style=';
    html += '                                    "margin:0px;padding:0px;list-style-type:none">';
    html += '                                    </ul>';
    html += '                                </td>';
    html += '                            </tr>';
    html += '                        </table>';
    html += '                    </div>';
    html += '                </div>';
    html += '';
    html += '                <div>';
    html += '<span  style="font-weight:bold">Quantity :</li></ul>';
    html += '                                    <input id="quantity" type=';
    html += '                                    "text" readonly style=';
    html += '                                    "margin-top:20px; " class="col-md-8">';
    html += '                                    <script type=';
    html += '                                    "text/javascript">';
    html += '';
    html += '                                    $("#quantity").TouchSpin({';
    html += '                                    min: 1,';
    html += '                                    max: 10,';
    html += '                                    stepinterval: 1,';
    html += '                                    maxboostedstep: 2,';
    html += '                                    initval:1';
    html += '                                    });';
    html += '                                    </script>';

    html += '                    <button onclick=';
    html += '                    "pageController.updateQuantity(' + '\'#quantity\'' + ');pageController.order()" type=';
    html += '                    "button" class="red-gradient-button">ORDER ';
    html += '                    NOW</button> <button id=';
    html += '                    "modify-items-close-button" onclick=';
    html += '                    "pageController.cancel()" type="button" class=';
    html += '                    "red-gradient-button" data-dismiss=';
    html += '                    "modal">CANCEL</button>';
    html += '                </div>';
    html += '            </div>';
    html += '        </div>';
    html += '    </div>';
    //html += '</div>';
    return html;
}

function ModalModifyOrderItem() {}
ModalModifyOrderItem.createMarkup = function () {
    var html = "";
    html += '    <div class="modal-dialog modal-lg">';
    html += '        <div class="modal-content">';
    html += '            <div class="modal-header">';
    html += '                <img onclick="pageController.cancel()" src=';
    html += '                "/img/closebutton.png" data-dismiss="modal"';
    html += '                aria-hidden="true">';
    html += '';
    html += '                <ul class="nav nav-tabs">';
    html += '                    <li class="active"><a class="white-no-shadow"';
    html += '                    href="#size-and-crust1" data-toggle="tab">SIZE';
    html += '                    &amp; TYPE</a></li>';
    html += '';
    html += '                    <li><a class="white-no-shadow" href=';
    html += '                    "#cheese-and-sauce1" data-toggle="tab">SAUCE</a></li>';
    html += '';
    html += '                    <li><a class="white-no-shadow" href="#toppings1"';
    html += '                    data-toggle="tab">TOPPINGS</a></li>';
    html += '                </ul>';
    html += '            </div>';
    html += '';
    html += '            <div class="modal-body">';
    html += '                <div class="tab-content">';
    html += '                    <div class="tab-pane fade active in" id=';
    html += '                    "size-and-crust1">';
    html += '                        <table>';
    html += '                            <tr>';
    html += '                                <td valign="top">';
    html += '                                    <ul class="left-column" style=';
    html += '                                    "margin:0px;padding:0px;list-style-type:none">';
    html += '                                    </ul>';
    html += '                                </td>';
    html += '';
    html += '                                <td valign="top">';
    html += '                                    <ul class="right-column" style=';
    html += '                                    "margin:0px;padding:0px;list-style-type:none;"></ul>';
    html += '                                </td>';
    html += '                            </tr>';
    html += '                        </table>';
    html += '                    </div>';
    html += '';
    html += '                    <div class="tab-pane fade" id=';
    html += '                    "cheese-and-sauce1">';
    html += '                        <table>';
    html += '                            <tr>';
    html += '                                <td valign="top">';
    html += '                                    <ul class="left-column" style=';
    html += '                                    "margin:0px;padding:0px;list-style-type:none">';
    html += '                                    </ul>';
    html += '                                </td>';
    html += '';
    html += '                                <td valign="top">';
    html += '                                    <ul class="right-column" style=';
    html += '                                    "margin:0px;padding:0px;list-style-type:none;">';
    html += '                                    </ul>';
    html += '                                </td>';
    html += '                            </tr>';
    html += '                        </table>';
    html += '                    </div>';
    html += '';
    html += '                    <div class="tab-pane fade" id="toppings1">';
    html += '                        <table>';
    html += '                            <tr>';
    html += '                                <td valign="top">';
    html += '                                    <ul class="left-column" style=';
    html += '                                    "margin:0px;padding:0px;list-style-type:none">';
    html += '                                    </ul>';
    html += '                                </td>';
    html += '                            </tr>';
    html += '                        </table>';
    html += '                    </div>';
    html += '                </div>';
    html += '';
    html += '                <div>';
    html += '<span  style="font-weight:bold" id="qntyHolder"></span>';
    html += '                                    <input id="quantity1" type=';
    html += '                                    "text" readonly style=';
    html += '                                    "margin-top:20px; " class="col-md-8">';
    html += '                                    <script type=';
    html += '                                    "text/javascript">';
    html += '';
    html += '                                    $("#quantity1").TouchSpin({';
    html += '                                    min: 1,';
    html += '                                    max: 10,';
    html += '                                    stepinterval: 1,';
    html += '                                    maxboostedstep: 2,';
    html += '                                    initval:1';
    html += '                                    });';
    html += '                                    </script>';
    html += '                    <button onclick=';
    html += '                    "pageController.updateQuantity(' + '\'#quantity1\'' + ');OrderItems.UpdateOrderItem()" type=';
    html += '                    "button" class="red-gradient-button">UPDATE';
    html += '                    </button> <button id=';
    html += '                    "modify-items-close-button" onclick=';
    html += '                    "pageController.cancel()" type="button" class=';
    html += '                    "red-gradient-button" data-dismiss=';
    html += '                    "modal">CANCEL</button>';
    html += '                </div>';
    html += '            </div>';
    html += '        </div>';
    html += '    </div>';
    //html += '</div>';
    return html;
}


function PanelOrderItemsSmall() {}
PanelOrderItemsSmall.createMarkup = function () {
    var html = "";
    var curr_loc = window.location.pathname;

    html += '<div class="panel-group" id="main-accordion">';
    html += '    <div class="panel panel-default">';
    html += '        <div class="panel-heading" style="background-color:#A49670">';
    html += '            <h4 class="panel-title">';
    html += '                 <a data-toggle="collapse" data-parent="#main-accordion" style="color:#fff;"  href="#childacc">';
    html += '                    <span class="itemSize">YOUR ORDER</span>';
    html += '                    <i class="glyphicon glyphicon-chevron-right" style="float:right"/>';
    html += '                 </a>';
    html += '            </h4>';
    html += '        </div>';
    html += '';
    html += '        <div id="childacc" class="panel-collapse collapse">';
    html += '            <div class="panel-body" id="childacc-container">';
    html += '                <table id="order-table-sm" cellspacing="10">';
    html += '                    <tbody></tbody>';
    html += '                </table>';
    html += '<br>';
    if (curr_loc.indexOf("confirmation") == -1) {
        html += '                <div width="100%" style="background-color:#A49685">';
        html += '                    <table id="promo" width="100%">';
        html += '                            <tr> ';
        html += '                                <td style="width:50%;text-align:center"> Enter your promo code </td>';
        html += '                                    <td><div class="col-lg-6" style="width:100%" >';
        html += '                                        <div class="input-group" style="margin-left:-10%">';
        html += '                                            <input type="text" class="form-control" id="promoCode-sm">';
        html += '                                                <span class="input-group-btn">';
        html += '                                                    <button class="btn btn-default" type="button" onclick="pageController.updatePromo()">Apply</button>';
        html += '                                                </span>';
        html += '                                        </div>';
        html += '                                    </div>';
        html += '                                </td>';
        html += '                            </tr>';
        html += '                    </table>';
        html += '                </div>';
    }
    html += '                <table id="order-totals-table-sm" cellspacing="10" width="100%" style="background-color:#BDAFA0">';
    html += '                    <thead>';
    html += '                        <tr>';
    html += '                            <th colspan="2">Order Total</th>';
    html += '                        </tr>';
    html += '                    </thead>';
    html += '                    <tbody></tbody>';
    html += '                </table>';
    html += '                <br><br>';
    html += '            </div>';
    html += '        </div>';
    html += '    </div>';
    html += '</div>';
    html += '<script  type="text/javascript"> $(function () { $("#main-accordion").click(function (e) { ';
    html += '$(e.target).siblings("i").toggleClass("glyphicon-chevron-right glyphicon-chevron-down");';
    html += '});';
    html += '});</script>';
    return html;
}

function PanelOrderItems() {}
PanelOrderItems.createMarkup = function () {
    var html = "";
    var curr_loc = window.location.pathname;

    html += '<div id="order-items-listing"><h2>Your Order</h2>'
    html += '<table id="order-table-right" cellspacing="10" >';
    html += '    <tbody></tbody>';
    html += '</table></div>';
    // html += '<br>';
    html += '<div class="order-table-total-wrapper">'

    if (curr_loc.indexOf("confirmation") == -1) {
        html += '                        <div class="promo-code-input">';
        html += '                            <input type="text" id="promoCode-lg" placeholder="Promo Code">';
        html +=                             '<button class="btn" type="button" onclick="pageController.updatePromo()">Apply</button>';
        html += '                        </div>';
    }
    html += '<h2>Order Total</h2><table id="order-totals-table-right" cellpadding="0" cellspacing="0" width="100%">';
    html += '    <tbody></tbody>';
    html += '</table></div>';
    return html;
}

function OrderItems() {}
OrderItems.buildYourOrder = function () {
    return false
    var orderDivArray = new Array();
    orderDivArray.push('right', 'sm');
    console.log('orderdivearray',orderDivArray.length)

    // Process all divs that need order data
    for (var orderDivIndex = 0; orderDivIndex < orderDivArray.length; orderDivIndex++) {

        var divName = orderDivArray[orderDivIndex];

        // Totals
        var orderSubTotal = Number(0.00);

        var html = "";
        html = "<tr>";
        if(Session.get('deliveryAvailable') == "true") {
            html += '    <td>' + Session.get('email') + ' (<a id="delivery-mode" style="font-size:80%;cursor: pointer; cursor: hand;color:#000;text-decoration:underline" onclick="+$(\'#modal-delivery\').modal();return false;">' + Session.get('mode') + '</a>) (<a href="#" style="font-size:80%;cursor: pointer; cursor: hand;color:#000;text-decoration:underline" onclick="CommonUtils.chooseStore()">' + Session.get('storeAddress') + ')</a></td>';
        }
        else {
            html += '    <td>' + Session.get('email') + ' (<a href="#" onclick="+$(\'#modal-delivery\').modal();return false;" id="delivery-mode" style="font-size:80%;cursor: pointer; cursor: hand;color:#000;text-decoration:underline">' + Session.get('mode') + '</a>) (<a href="#" style="font-size:80%;cursor: pointer; cursor: hand;color:#000;text-decoration:underline" onclick="CommonUtils.chooseStore()">' + Session.get('storeAddress') + ')</a></td>';
        }

        html += "</tr>";

        // Process all order items
        var orderItems = JSON.parse(Session.get('orderItems'));
        var curr_loc = window.location.pathname;

        var userPromos = JSON.parse(Session.get('userPromoCodes'));
        var promoCost = 0.0;

        for (var j = 0; j < userPromos.length; j++) {
            promoCost += Number(userPromos[j]['cost']);
        }

            console.log(orderItems.length);
        for (var ii = 0; ii < orderItems.length; ii++) {
            // console.log('test');
            var orderItem = orderItems[ii];

            var cost = Number(orderItem['cost']);
            orderSubTotal += (cost * Number(orderItem['quantity']));
            var orderCost = (cost * Number(orderItem['quantity']));
            var $size = '';

            html += '<tr>';
            html += '    <td>';
            html += '        <div class="panel-group" id="accordion-' + divName + '-' + orderItem['id'] + '">'
            html += '            <div class="panel panel-default">'
            html += '                <div style="margin: 0 -6px -6px;"><table width="100%" cellspacing="10" class="order-item-table"><tr>'
            html += '                    <td><span style="float:right" class="itemQty"><b>&times; ' + orderItem['quantity'] + '</b></span>'
            html += '<a class="removeItem" onClick="OrderItems.cancelOrder(' + orderItem['id'] + ');">&times;</a>';
            if (typeof orderItem['size'] === 'object' && orderItem['size']['id'] != 'NULL') {
                $size = orderItem['size']['description'].toUpperCase().substr(0,2);
                if($size == 'LA')
                    $size = "LG"
                html += '       <span class="itemSize" data-size="'+orderItem['size']['description']+'">' + $size + '</span> '
            }
            html += '                         <a class="accordion-toggle" data-toggle="collapse" style="display:block;color:#fff;font-size:14px" data-parent="#accordion-' + divName + '-' + orderItem['id'] + '" href="#order-item-detail-' + divName + '-' + orderItem['id'] + '">'
            
            html += '<span class="itemDescription">' + orderItem['item']['name'] +'</span>';
            html += '                         </a>'
            html += '</td><td> $' + orderCost.toFixed(2) + '</td>'
            html += '                    </tr></table></div>'
            html += '                </div>'
            html += '                <div id="order-item-detail-' + divName + '-' + orderItem['id'] + '" class="panel-collapse collapse" style="margin-top:6px">'
            html += '                    <div class="panel-body">'
            if (curr_loc.indexOf("confirmation") == -1) {
                // html += '<span class="badge" style="float:right"><a style="font-size:80%;cursor: pointer; cursor: hand;text-decoration:underline;color:#000" onClick="pageController.updateOrder(' + orderItem['id'] + ');">Edit</a></span>';
            }
            if (typeof orderItem['style'] === 'object' && orderItem['style']['id'] != 'NULL') {
                html += '                        <p>Style: ' + orderItem['style']['description'] + '</p>'
            }
            if (typeof orderItem['item'] === 'object' && orderItem['item']['detail'] > '') {
                html += '                        <p style="font-style:italic">' + orderItem['item']['detail'] + '</p>'
            }
            if (typeof orderItem['toppers'] === 'object' && orderItem['toppers'].length != 'undefined'  && orderItem['toppers'].length > 0) {
                html += '<div><div><b>Toppers</b></div>'
                for (var i = 0; i < orderItem['toppers'].length; i++) {
                    
                    html += '<span>' + orderItem['toppers'][i]['description'] + '</span>'
                    if(i+1 !== orderItem['toppers'].length)
                    html += ', '
                };
                html += '</div>'
            }
            if (orderItem['orderType'] == "PIZZA") {
                html += '                        <p>Sauce: ' + orderItem['sauce']['description'] + '</p>'
            }
            html += '                        <p>Sauce Options: ' + orderItem['sauceModifier']['description'] + '</p>'
            html += '                        <p>Toppings: <br>'
            // Toppings
            var toppings = orderItem['toppings']
            if(toppings) {
                for (var toppingIndex = 0; toppingIndex < toppings.length; toppingIndex++) {
                    var topping = toppings[toppingIndex];
                    html += topping['description'] + ' - ' + topping['portion'] + "<br>";
                }
            }
            html += '                        </p>'
            html += '                    </div>'
            html += '                </div>'
            html += '            </div>'
            html += '        </div>'
            html += '    </td>';
            html += "</tr>";
        }

        html += buildPromoAccordion(promoCost, userPromos, divName);
        $('#order-table-' + divName + ' > tbody').html(html);

        // Order Totals
        var orderTaxes          = 0.00;
        var orderTip            = 0.00;
        var orderDeliveryCharge = 0.00;
        var orderDriverMoney    = 0.00;
        var orderTotal          = 0.00;

        if (Session.get('orderTax')) {
            orderTaxes = Number(Session.get('orderTax'));
        }

        if (Session.get('orderTax2')) {
            orderTaxes2 = Number(Session.get('orderTax2'));
            orderTaxes  += orderTaxes2;
        }

        if (Session.get('orderTip')) {
            orderTip = Number(Session.get('orderTip'));
        }

        if (Session.get('deliveryCharge') && Session.get('mode') == 'Delivery') {
            orderDeliveryCharge = Number(Session.get('deliveryCharge'));
        }

        if (Session.get('driverMoney') && Session.get('mode') == 'Delivery') {
            orderDriverMoney = Number(Session.get('driverMoney'));
        }

        orderTotal = orderSubTotal + orderTaxes + orderTip + orderDeliveryCharge + orderDriverMoney - promoCost; //Subtracting promocode price    
        html = "";

        html += '<tr>';
        html += '    <td>SUB TOTAL</td>';
        html += '    <td align="right">$ ' + orderSubTotal.toFixed(2) + '</th>';
        html += '</tr>';
        html += '<tr>';
        html += '    <td>TAXES</td>';
        html += '    <td align="right">$ ' + orderTaxes.toFixed(2) + '</span></th>';
        html += '</tr>';
        html += '<tr>';
        html += '    <td>DELIVERY CHARGE:</td>';
        html += '    <td align="right">$ ' + orderDeliveryCharge.toFixed(2) + '</span></th>';
        html += '</tr>';
        html += '<tr>';
        html += '    <td>DRIVER MONEY:</td>';
        html += '    <td align="right">$ ' + orderDriverMoney.toFixed(2) + '</span></th>';
        html += '</tr>';
        html += '<tr>';
        html += '    <td>TIP</td>';
        html += '    <td align="right"> $ ';
 
        if (curr_loc.indexOf("confirmation") != -1) {
            html += orderTip.toFixed(2);
        } else {
            html += '<input type="text" class="ordrTip" value="' + orderTip + '" maxlength="4" size="4" style="text-align:right" onchange="OrderItems.clearField(this.value)" onblur="OrderItems.UpdateTip()"/>';
        }
        html += '</td>';
        html += '</tr>';
        // if (curr_loc.indexOf("confirmation") == -1) {
        //     html += ' <tr><td align="right" colspan="2"> <a style="font-size:80%;cursor: pointer; cursor: hand;text-decoration:underline;color:#000" onclick="OrderItems.UpdateTip()">Apply</a></td>';
        //     html += '</tr>';
        // }

        html += '<tr>';
        html += '    <th colspan="2"><hr></th>';
        html += '</tr>';
        html += '<tr class="total-line">';
        html += '    <td>TOTAL</td>';
        html += '    <td align="right" id="total">$ ' + orderTotal.toFixed(2) + '</td>';
        html += '</tr>';
        html += '<tr>';
        if (curr_loc.indexOf("information") == -1 && curr_loc.indexOf("confirmation") == -1) {
            if (orderItems.length > 0)
                html += '    <th colspan="2"><hr> <button onclick="window.location.href=\'/order-information\'" type="button" class="red-gradient-button">SUBMIT ORDER</button></td>';
        }
        html += '</tr>';

        $('#order-totals-table-' + divName + ' > tbody').html(html);
        $(document).off('scroll.order-table')
        $(document).off('resize.order-table')
        var top = $("#order-items-listing").outerHeight() + $("#order-items-listing").offset().top
        var topOffset = $("#order-items-listing").offset().top - 20
        var topHeight = $("#order-items-listing").outerHeight() 
        var rightSide = $(document).width()-$("#order-items-panel").offset().left-$("#order-items-panel").outerWidth();
        var adjustOrderTotal = function(){
            var avail = $(window).height()-$(".order-table-total-wrapper").outerHeight();
            // console.log(top, $(window).scrollTop(), avail,$("#order-items-listing").outerHeight(),top-avail)
            if($(window).scrollTop() > top - avail) {
                $(".order-table-total-wrapper").css('width',$("#order-items-panel").outerWidth()).addClass('fixed').css('right',rightSide)
            } else {
                $(".order-table-total-wrapper").css('width','auto').removeClass('fixed').css('right','auto')
            }
            if($(window).scrollTop() > topOffset) {
                if(avail > topHeight + 60 ) {
                    $("#order-items-listing").css('width',$("#order-items-panel").outerWidth()).css('max-height',avail).addClass('fixed').css('right',rightSide)
                }
            } else {
                if(avail > topHeight + 60) {
                    $("#order-items-listing").removeClass('fixed').css('width','auto').css('max-height','none').css('right','auto')
                }
            }

        }
        reCheckPoints = function(){
            top = $("#order-items-listing").outerHeight() + $("#order-items-listing").offset().top
            topOffset = $("#order-items-listing").offset().top - 20
            topHeight = $("#order-items-listing").outerHeight() 
            rightSide = $(document).width()-$("#order-items-panel").offset().left-$("#order-items-panel").outerWidth();
        }
        $(document).on('scroll.order-table',adjustOrderTotal)
        $(window).on('resize.order-table',adjustOrderTotal)
        $(window).on('resize.order-table',reCheckPoints)
        adjustOrderTotal()

    }


    // this method helps to cancel the order. It cancels one order at a time.
    OrderItems.cancelOrder = function (id) {
        var json = {
            "OrderLineID": id
        }

        //An ajax call to cancel the order in the back end
        $.ajax({
            url: "/rest/view/order-line/delete-order-line",
            type: "POST",
            data: JSON.stringify(json),
            success: function (data) {

                //It updates the orderItems resides in session after deletion
                var orderItems = JSON.parse(Session.get('orderItems'));
                var updatedOrderItems = new Array();

                for (var i = 0; i < orderItems.length; i++) {
                    var orderItem = orderItems[i];
                    if (orderItem['id'] != id) {
                        updatedOrderItems.push(orderItem);
                    }
                }

                Session.set('orderItems', JSON.stringify(updatedOrderItems));

                //It rebuilds the accordion after deletion
                OrderItems.buildYourOrder();
            }
        });
    }

    OrderItems.clearField = function (val) {
        Session.set('currentTip', val);
    }

    OrderItems.UpdateTip = function () {
        var tip = Session.get('currentTip');

        if (tip == null || tip == undefined || isNaN(parseFloat(tip)))
            tip = 0;
        Session.set('orderTip', tip);

        OrderItems.buildYourOrder();
    }
    OrderItems.UpdateOrderItem = function () {
        $('#modal-modify-item1').modal('hide');
        $('#modal-please-wait').modal('show');
        var orderLineId = Session.get('selectedOrderLineId');
        if (orderLineId) {
            var orderItems = JSON.parse(Session.get('orderItems'));
            var selectedOrderItem;

            for (var i = 0; i < orderItems.length; i++) {
                var orderItem = orderItems[i];
                if (orderItem['id'] == orderLineId) {
                    selectedOrderItem = orderItem;
                }
            }

            if (selectedOrderItem) {
                selectedOrderItem['quantity'] = Session.get('quantity');
                //size

                var sizeId = Session.get('sizeId');
                var sizeInSsn = JSON.parse(Session.get(selectedOrderItem['orderType'] + '_SIZES'));
                for (var i = 0; i < sizeInSsn.length; i++) {
                    if (sizeId == sizeInSsn[i]['id']) {
                        selectedOrderItem['size'] = sizeInSsn[i];
                    }
                }

                //style

                var styleId = Session.get('styleId');
                var styleInSsn = JSON.parse(Session.get(selectedOrderItem['orderType'] + '_STYLES'));
                for (var i = 0; i < styleInSsn.length; i++) {
                    if (styleId == styleInSsn[i]['id']) {
                        selectedOrderItem['style'] = styleInSsn[i];
                    }
                }

                // Get sauce
                var sauceId = Session.get('sauceId');
                var sauceInSsn = JSON.parse(Session.get(selectedOrderItem['orderType'] + '_SAUCES'));
                for (var i = 0; i < sauceInSsn.length; i++) {
                    if (sauceId == sauceInSsn[i]['id']) {
                        selectedOrderItem['sauce'] = sauceInSsn[i];
                    }
                }

                // Get sauce modifier
                var sauceModifierId = Session.get('sauceModifierId');
                if (sauceModifierId) {
                    var sauceModInSsn = JSON.parse(Session.get(selectedOrderItem['orderType'] + '_SAUCEMODIFIERS'));
                    for (var i = 0; i < sauceModInSsn.length; i++) {
                        if (sauceModifierId == sauceModInSsn[i]['id']) {
                            selectedOrderItem['sauceModifier'] = sauceModInSsn[i];
                        }
                    }
                } else {
                    selectedOrderItem['sauceModifier'] = {
                        id: "NULL",
                        description: ""
                    };
                }
                //topper

                selectedOrderItem['toppers'] = new Array();
                var selectedToppers = JSON.parse(Session.get('ToppersInEdit'));
                var topperInSsn = JSON.parse(Session.get(selectedOrderItem['orderType'] + '_TOPPERS'));

                for (var i = 0; i < selectedToppers.length; i++) {
                    var topperId = selectedToppers[i];
                    for (var j = 0; j < topperInSsn.length; j++) {
                        if (topperId == topperInSsn[j]['id']) {
                            selectedOrderItem['toppers'].push(topperInSsn[j]);
                        }
                    }
                }
                //topping

                var toppingsString = Session.get('toppings');
                var toppings       = JSON.parse(toppingsString);

                selectedOrderItem['toppings'] = new Array();

                for (var i = 0; i < toppings.length; i++) {
                    var item = toppings[i];
                    var elements = item.split('-');

                    var itemId = elements[0];

                    var portion = elements[1].split('+')[0];
                    var topping = {};
                    topping['id'] = itemId;
                    topping['portion'] = portion;
                    topping['description'] = elements[1].split('+')[1];
                    selectedOrderItem['toppings'].push(topping);
                }

                Session.set('orderItems', JSON.stringify(orderItems));
                $('#modal-please-wait').modal('hide');
                OrderItems.buildYourOrder();
            }
        }
    }
}

function buildPromoAccordion(promoCost, userPromos, divName) {
    var html = '';


    if (userPromos.length > 0) {
        html += '<tr>';
        html += '    <td>';
        html += '        <div class="panel-group" id="accordion-promo-' + divName + '">'
        html += '            <div class="panel panel-default">'
        html += '                <div style="background-color:#A49685;height:38px">'
        html += '                    <h3 class="panel-title">'
        html += '                         <div class="col-xs-9"> <a data-toggle="collapse" style="color:#fff;font-size:14px" data-parent="#accordion-promo-' + divName + '" href="#promo-detail-' + divName + '">'
        html += '<span style="font-size:14px;">Promo</span></a></div>';
        html += '<div class="col-sm-2" style="height:38px;font-size:15px;float:right;"><div style="float:right" class="row">$ -' + promoCost.toFixed(2);
        html += '                         </div></div>'
        html += '                    </h3>'
        html += '                </div>'
        html += '                <div id="promo-detail-' + divName + '" class="panel-collapse collapse ">'
        html += '                    <div class="panel-body" style="font-size:12px;background-color:#BDAFA0">' //A49670">'
        html += ' <div style="height:76px;width:25%;margin-top:-27px;margin-left:-25px" class="row titleimage"></div> ';
        for (var i = 0; i < userPromos.length; i++) {
            var userPromo = userPromos[i];
            html += '                        <p>Code : ' + userPromo['code'] + '</p>'
            html += '                        <p>Description : ' + userPromo['description'] + '</p>'
            html += '                        <p>Cost : $' + Number(userPromo['cost']).toFixed(2) + '</p>'
            if (i < userPromos.length - 1)
                html += '<hr>';
        }
        html += '                    </div>'
        html += '                </div>'
        html += '            </div>'
        html += '        </div>'
        html += '    </td>';
        html += '</tr>';
    }
    return html;
}
