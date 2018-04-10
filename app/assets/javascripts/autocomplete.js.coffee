jQuery ($)->
  $(document).on 'change', 'input.autocomplete-field', ->
    if /^\s*$/.test($(this).val())
      $(this).next('input.autocomplete-id:first').val('')

  $(document).on 'focus', 'input.autocomplete-field:not([data-observed])', ->
    input = $(this)

    input.autocomplete
      source: (request, response)->
        $.ajax
          url: input.data('autocompleteUrl')
          dataType: 'json'
          data: { q: request.term }
          success: (data)->
            response $.map data, (item)->
              item = item.client
              content = $('<div></div>')

              content.append $('<span class="title"></span>').text(item.label)

              if item.document
                content.append $('<small></small>').text(item.document)

              { label: content.html(), value: item.label, item: item }
      type: 'get'
      select: (event, ui)->
        selected = ui.item

        input.val(selected.value)
        input.data('item', selected.item)
        $(input.data('autocompleteIdTarget')).val(selected.item.id)
        if selected.item.bill_kind
          $(input.data('autocomplete-bill-kind-target')).val(
            selected.item.bill_kind).attr('selected', true)

        if selected.item.client_kind
          $(
            input.data('autocomplete-client-kind-target')
          ).val(selected.item.client_kind)

        if selected.item.uic
          $(input.data('autocomplete-uic-target')).val(selected.item.uic)

        if selected.item.uic_type
          $(
            input.data('autocomplete-uic-type-target')
          ).val(selected.item.uic_type)

        input.trigger 'autocomplete:update', input

        false

      open: -> $('.ui-menu').css('width', input.width())

    input.data('ui-autocomplete')._renderItem = (ul, item)->
      ul.addClass('typeahead dropdown-menu')
      $('<li></li>').data('item.autocomplete', item).append(
        $('<a></a>').html(item.label)
      ).appendTo(ul)
  .attr('data-observed', true)
