$(function(){
    $('.chzn-select').select2();
    $(".ein").mask("99-9999999");
    $(".phone").mask("(999) 999-9999");
    $(".zip").mask("99999-9999");
    $(".credit").mask("9999-9999-9999-9999");
    $(".percent").mask("999.99%");
    $(".currency").mask("$999.99");
    $(".date-entry").datepicker();
    $("#wizard").bootstrapWizard({onTabShow: function(tab, navigation, index) {
        var $total = navigation.find('li').length;
        var $current = index+1;
        var $percent = ($current/$total) * 100;
        var $wizard = $("#wizard");
        $wizard.find('.progress-bar').css({width:$percent+'%'});

        if($current >= $total) {
            $wizard.find('.pager .next').hide();
            $wizard.find('.pager .finish').show();
            $wizard.find('.pager .finish').removeClass('disabled');
        } else {
            $wizard.find('.pager .next').show();
            $wizard.find('.pager .finish').hide();
        }
    }});
});

