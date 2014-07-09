main = ->
  addListeners()

addListeners = ->
  document.getElementById('expand-quick-contact').addEventListener 'mousedown', expandQuickContact
  #document.getElementById('show-projects-btn').addEventListener 'mousedown', showProjects

expandQuickContact = ->
  elems = document.getElementById('quick-contact').childNodes
  i = 0
  len = elems.length

  while i < len
    elems[i].removeAttribute 'class'  if elems[i].nodeType is Node.ELEMENT_NODE
    i++
  eqc = document.getElementById('expand-quick-contact')
  eqc.parentNode.removeChild eqc

showProjects = ->
  btn = document.getElementById('show-projects-btn')
  btn.parentNode.removeChild btn
  $('.project-row.hidden').removeClass 'hidden'
  return

$(document).ready main
