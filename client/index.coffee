main = ->
  addListeners()

addListeners = ->
  $('#expand-quick-contact').mousedown expandQuickContact

expandQuickContact = ->
  $('#quick-contact li').each -> $(this).removeClass 'hidden'
  $('#expand-quick-contact').remove()

$(document).ready main
