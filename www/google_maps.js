// Google Maps functionality for Shiny app
let map;
let service;
let infowindow;
let markers = [];
let lagMadreLayer;
let playaBagdadLayer;
let dvLayer;

// Initialize Google Maps
function initMap() {
  // Center on Playa Bagdad, Tamaulipas, Mexico
  const playaBagdad = { lat: 25.9167, lng: -97.1500 };
  
  map = new google.maps.Map(document.getElementById("google_map"), {
    center: playaBagdad,
    zoom: 12
  });
  
  infowindow = new google.maps.InfoWindow();
  
  // Add a marker for Playa Bagdad
  new google.maps.Marker({
    position: playaBagdad,
    map: map,
    title: "Playa Bagdad",
    icon: {
      url: "https://maps.google.com/mapfiles/ms/icons/blue-dot.png"
    }
  });

  // Cargar y configurar la capa de Laguna Madre
  try {
    const geojsonScript = document.getElementById('lag_madre_geojson');
    if (geojsonScript && geojsonScript.textContent) {
      const lagMadreData = JSON.parse(geojsonScript.textContent);
      lagMadreLayer = new google.maps.Data();
      lagMadreLayer.addGeoJson(lagMadreData);
      lagMadreLayer.setStyle({
        fillColor: '#008f39', // Un verde distintivo
        strokeWeight: 1.5,
        strokeColor: '#004d1f',
        fillOpacity: 0.3
      });
    }
  } catch (e) {
    console.error("Error al cargar o procesar la capa GeoJSON de Laguna Madre:", e);
  }

  // Cargar y configurar la capa de Playa Bagdad
  try {
    const geojsonScript = document.getElementById('playa_bagdad_geojson');
    if (geojsonScript && geojsonScript.textContent) {
      const playaBagdadData = JSON.parse(geojsonScript.textContent);
      playaBagdadLayer = new google.maps.Data();
      playaBagdadLayer.addGeoJson(playaBagdadData);
      playaBagdadLayer.setStyle({
        fillColor: '#0077b6', // Un azul distintivo
        strokeWeight: 1.5,
        strokeColor: '#023e8a',
        fillOpacity: 0.4
      });
    }
  } catch (e) {
    console.error("Error al cargar o procesar la capa GeoJSON de Playa Bagdad:", e);
  }

  // Cargar y configurar la capa Dv
  try {
    const geojsonScript = document.getElementById('dv_layer_geojson');
    if (geojsonScript && geojsonScript.textContent) {
      const dvLayerData = JSON.parse(geojsonScript.textContent);
      dvLayer = new google.maps.Data();
      dvLayer.addGeoJson(dvLayerData);
      dvLayer.setStyle({
        fillColor: '#fca311', // Un naranja distintivo
        strokeWeight: 1.5,
        strokeColor: '#e85d04',
        fillOpacity: 0.5
      });

      // Añadir un listener para el evento 'click'
      dvLayer.addListener('click', function(event) {
        // Mostrar un InfoWindow temporal
        infowindow.setContent('<h4>Recorrido CONANP</h4><p>Abriendo galería de fotos...</p>');
        infowindow.setPosition(event.latLng);
        infowindow.open(map);
        // Enviar una señal a Shiny para que sepa que se hizo clic
        Shiny.setInputValue('dv_layer_clicked', Math.random());
      });

    }
  } catch (e) {
    console.error("Error al cargar o procesar la capa GeoJSON de Dv:", e);
  }
}

// Función para mostrar/ocultar la capa de Laguna Madre
function toggleLagMadreLayer(show) {
  if (lagMadreLayer) {
    lagMadreLayer.setMap(show ? map : null);
  }
}

// Función para mostrar/ocultar la capa de Playa Bagdad
function togglePlayaBagdadLayer(show) {
  if (playaBagdadLayer) {
    playaBagdadLayer.setMap(show ? map : null);
  }
}

// Función para mostrar/ocultar la capa Dv
function toggleDvLayer(show) {
  if (dvLayer) {
    dvLayer.setMap(show ? map : null);
  }
}

// Search for places
function searchPlaces() {
  // Clear previous markers
  clearMarkers();
  
  const searchQuery = document.getElementById("search_place").value;
  const placeType = document.getElementById("place_type").value;
  const radius = document.getElementById("search_radius").value * 1000; // Convert to meters
  
  if (!searchQuery && !placeType) {
    alert("Por favor ingresa un término de búsqueda o selecciona un tipo de lugar");
    return;
  }
  
  const request = {
    location: map.getCenter(),
    radius: radius,
    keyword: searchQuery
  };
  
  if (placeType && placeType !== "all") {
    request.type = placeType;
  }
  
  service = new google.maps.places.PlacesService(map);
  service.nearbySearch(request, (results, status) => {
    if (status === google.maps.places.PlacesServiceStatus.OK) {
      displayPlaces(results);
    } else {
      console.error("Error searching places:", status);
      document.getElementById("places_results").innerHTML = 
        "<p style='color: red;'>Error al buscar lugares. Intenta con otros términos.</p>";
    }
  });
}

// Display places on map and in results
function displayPlaces(places) {
  const resultsContainer = document.getElementById("places_results");
  let resultsHTML = "<div class='places-list'>";
  
  places.forEach((place, index) => {
    // Create marker
    const marker = new google.maps.Marker({
      position: place.geometry.location,
      map: map,
      title: place.name,
      animation: google.maps.Animation.DROP
    });
    
    markers.push(marker);
    
    // Create info window content
    const infoContent = `
      <div style="min-width: 200px;">
        <h5 style="margin: 0 0 10px 0; color: #2c3e50;">${place.name}</h5>
        ${place.rating ? `<p style="margin: 5px 0; color: #f39c12;">⭐ ${place.rating}/5 (${place.user_ratings_total || 0} reseñas)</p>` : ''}
        ${place.vicinity ? `<p style="margin: 5px 0; color: #7f8c8d;">📍 ${place.vicinity}</p>` : ''}
        ${place.types ? `<p style="margin: 5px 0; font-size: 12px; color: #95a5a6;">🏷️ ${place.types.join(', ')}</p>` : ''}
        ${place.opening_hours ? `<p style="margin: 5px 0; color: ${place.opening_hours.open_now ? '#27ae60' : '#e74c3c'};">🕒 ${place.opening_hours.open_now ? 'Abierto' : 'Cerrado'}</p>` : ''}
      </div>
    `;
    
    // Add click listener to marker
    marker.addListener("click", () => {
      infowindow.setContent(infoContent);
      infowindow.open(map, marker);
    });
    
    // Add to results list
    resultsHTML += `
      <div class="place-item" style="border-bottom: 1px solid #ecf0f1; padding: 10px 0; cursor: pointer;" 
           onclick="showPlaceInfo(${index})">
        <h6 style="margin: 0 0 5px 0; color: #2c3e50;">${place.name}</h6>
        ${place.rating ? `<span style="color: #f39c12; font-size: 12px;">⭐ ${place.rating}/5</span> ` : ''}
        ${place.vicinity ? `<span style="color: #7f8c8d; font-size: 12px;">📍 ${place.vicinity}</span>` : ''}
      </div>
    `;
  });
  
  resultsHTML += "</div>";
  resultsContainer.innerHTML = resultsHTML;
  
  // Fit map to show all markers
  if (markers.length > 0) {
    const bounds = new google.maps.LatLngBounds();
    markers.forEach(marker => bounds.extend(marker.getPosition()));
    map.fitBounds(bounds);
  }
}

// Show place info when clicking on result item
function showPlaceInfo(index) {
  if (markers[index]) {
    google.maps.event.trigger(markers[index], 'click');
    map.panTo(markers[index].getPosition());
  }
}

// Clear all markers
function clearMarkers() {
  markers.forEach(marker => marker.setMap(null));
  markers = [];
}

// Initialize map when page loads
document.addEventListener('DOMContentLoaded', function() {
  // Check if Google Maps API is loaded
  if (typeof google !== 'undefined' && google.maps) {
    initMap();
  } else {
    // Wait for API to load
    window.initMap = initMap;
  }
});

// Add event listeners for search button
document.addEventListener('click', function(e) {
  if (e.target && e.target.id === 'search_btn') {
    searchPlaces();
  }
});

// Add keyboard support for search
document.addEventListener('keypress', function(e) {
  if (e.target && e.target.id === 'search_place' && e.key === 'Enter') {
    searchPlaces();
  }
}); 