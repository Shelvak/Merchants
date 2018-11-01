jQuery(function(){
//    Autocalculate the finalprice
        $('#pricedist,#iva,#earn').keyup(function() {
          $('#price').attr('value',$('#pricedist').val() *
            (parseFloat($('#iva').val())/100 + 1) *
            (parseFloat($('#earn').val())/100 + 1) );
        });

        //   Delete the "snowman" from search and disable the button
        $('form').submit(function() {
           $(this).find('input[type="submit"],\n\
                input[name="utf8"]').attr('disabled', true);
        });

//      Calcule the new stock
        var originalStock = parseFloat($('#stock').val());
        $('#newstock').on('change', function() {
           if ($('#newstock').val() == "" ){
             $('#stock').attr('value', originalStock);
           } else {
             newStock = parseFloat( $('#newstock').val() )
             if (newStock >= 0) {
               $('#stock').attr('value', originalStock + newStock);
             }
           }

        });

        $('.excel_with_month').on('click', function() {
          month = prompt('Ingrese el numero del mes');
          year = prompt('Ingrese el numero del año YYYY');
          console.log(window.location)
          url = window.location.pathname + ".csv?year=" + year + "&month=" + month;
          window.location = url;
        });


});
