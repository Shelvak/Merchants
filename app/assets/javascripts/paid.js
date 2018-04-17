jQuery(function($){
//    do "Paid" in mounth
        $('a.paid').on('ajax:success',function(xhr,data){
            $(this).parents('tr:first').replaceWith(data);
        });


        // Clean and focus search
         $('.search').attr('value', null).focus();

        // sum to amount
        var amount = parseFloat($('#amount').val() || 0);
        var original = parseFloat($('#amount').val() || 0);
        $('#to_amount').on('change', function() {

           if ($('#to_amount').val() == "" ){
               $('#amount').attr('value', original);
            }else {
                amount += parseFloat( $('#to_amount').val() )
                amount = (Math.round(amount*100) /100 ).toFixed(2)
                $('#amount').attr('value', amount);
                amount = original;}

        });

        // Calcule the total price in new order
            var count = $('.order-quantity').length;
            var original_total = parseFloat(
                $('#order_total_price').text().replace('$','').replace(',','.')
            );
            var new_total = original_total;
            $('.price-modifier').on('change', function() {
            new_total = 0;
            for (i=0; i< count; i++){
                price = "#order_line_items_attributes_" + i + "_price";
                quantity = "#order_line_items_attributes_" + i + "_quantity";
                price = parseFloat($(price).val());
                quantity = parseFloat($(quantity).val());
                parcial = parseFloat(price * quantity);
                new_total = parseFloat(new_total + parcial);
            }

            discount_element = $("#order_discount");
            if(discount_element.val() >= 0 && discount_element.val() <= 100){
                discount = parseFloat(1 - discount_element.val()/100);
                new_total = parseFloat(new_total * discount);
            }
             new_total = new_total.toFixed(2);
             new_total = new_total.replace('.', ',');
             $('#order_total_price').text('$' + new_total);
        });


});
