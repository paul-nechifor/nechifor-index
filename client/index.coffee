main = ->
  addListeners()
  loadGoogleMap()

addListeners = ->
  document.getElementById('expand-quick-contact').addEventListener 'mousedown', expandQuickContact
  document.getElementById('show-projects-btn').addEventListener 'mousedown', showProjects

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

loadGoogleMap = ->
  script = document.createElement('script')
  script.type = 'text/javascript'
  script.src = 'https://maps.googleapis.com/maps/api/js?v=3.exp&sensor=false&callback=initializeGoogleMap'
  document.body.appendChild script

initializeGoogleMap = ->
  latLng = new google.maps.LatLng(47.16, 27.58)
  mapOptions =
    zoom: 5
    center: latLng
    mapTypeId: google.maps.MapTypeId.ROADMAP
    disableDefaultUI: true
    scrollwheel: false
    draggable: false

  map = new google.maps.Map(document.getElementById('map-canvas'), mapOptions)
  marker = new google.maps.Marker(
    position: latLng
    map: map
  )
  infowindow = new google.maps.InfoWindow(content: "<div style='width:120px;height:24px;font-size:18px;text-align:center'>Iași, România</div>")
  infowindow.open map, marker

$(document).ready main
