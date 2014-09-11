function SignInController () {
    
    this.constructSession = function(){
        // Session.createSession();
        Session.set('orderItems', JSON.stringify(new Array()));
        Session.set('userPromoCodes',JSON.stringify(new Array()));
        Session.set('PIZZA_TOPPERS',JSON.stringify(new Array()));
        Session.set('SUBS_TOPPERS',JSON.stringify(new Array()));
        Session.set('SALADS_TOPPERS',JSON.stringify(new Array()));
        Session.set('PIZZA_SIZES',JSON.stringify(new Array()));
        Session.set('SUBS_SIZES',JSON.stringify(new Array()));
        Session.set('SALADS_SIZES',JSON.stringify(new Array()));
        Session.set('PIZZA_SAUCES',JSON.stringify(new Array()));
        Session.set('SUBS_SAUCES',JSON.stringify(new Array()));
        Session.set('SALADS_SAUCES',JSON.stringify(new Array()));
        Session.set('PIZZA_STYLES',JSON.stringify(new Array()));
        Session.set('SUBS_STYLES',JSON.stringify(new Array()));
        Session.set('SALADS_STYLES',JSON.stringify(new Array()));
        Session.set('SIDES_STYLES',JSON.stringify(new Array()));
        Session.set('PIZZA_SAUCEMODIFIERS',JSON.stringify(new Array()));
        Session.set('SUBS_SAUCEMODIFIERS',JSON.stringify(new Array()));
        Session.set('SALADS_SAUCEMODIFIERS',JSON.stringify(new Array()));
        Session.set('PIZZA_TOPPINGS',JSON.stringify(new Array()));
        Session.set('SUBS_TOPPINGS',JSON.stringify(new Array()));
        Session.set('SALADS_TOPPINGS',JSON.stringify(new Array()));
    }
 
    this.init = function() {
        geo = new google.maps.Geocoder();
        delay = 100;
    
        $('#nav-container').append(NavBar.createMarkup());

        $('#main').append(ModalPleaseWait.createMarkup('modal-please-wait', 'Please wait'));
        $('#main').append(ModalInvalidLogin.createMarkup('modal-invalid-login', 'Click to try again'));
        $('#main').append(ModalLocation.createMarkup('modal-location', 'LOCATION CLOSEST TO YOU'));
        $('#main').append(ModalDelivery.createMarkup('modal-delivery', 'HOW WOULD YOU LIKE YOUR ORDER?','YES'));
        $('#main').append(ModalStores.createMarkup('modal-stores', 'CHOOSE STORE'));
        $('#main').append(ModalStoreIsClosed.createMarkup('modal-store-is-closed', 'OK'));

    }

    this.signIn = function() {
        var email    = $("#sign-in-email-address").val();
        var password = $("#sign-in-password").val();

        password = $.md5(password);

        var json = {
            email: email,
            password: password
        }

        $('#modal-please-wait').modal('show');

        $.ajax({
            url: "/rest/view/customer/get-customer",
            type: "POST",
            data: JSON.stringify(json),
            success: function(data) {
                if(data != '') {
                    console.log(data);
                    var customer     = data[0]
                    var email        = customer['EMail'];
                    var addressLine1 = customer['AddressLine1'];
                    var postalCode   = customer['PostalCode'];

                    Session.set('email', email);

                    search = addressLine1 + " " + postalCode;
                    CommonUtils.findStore(search, true);
                }
                else {
                    $('#modal-please-wait').modal('hide');
                    $('#modal-invalid-login').modal('show');
                }
            },
            error: function() {
                $('#modal-please-wait').modal('hide');
                $('#modal-invalid-login').modal('show');
            }

        });
        
    }

    this.signUp = function() {

        var email  = $("#sign-up-email-address").val();
        var zip    = $("#sign-up-zip-code").val();
        var street = $("#sign-up-street").val();
        var apt    = $("#sign-up-apt").val();

        console.log("Email: " + email);
        console.log("Address Line 1: " + street);

        Session.set('email', email);
        Session.set('apt', apt);

        $('#modal-please-wait').modal('show');
        search = street + " " + zip;
        CommonUtils.findStore(search, true);
    }


}
