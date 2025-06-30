// Google Maps functionality for Shiny app
let map;
let service;
let infowindow;
let markers = [];
let lagMadreLayer;
let playaBagdadLayer;
let dvLayer;
let aicasLayer;
let sistema_arrecifal_tamaulipasLayer;
let rtpLayer;
let rmpLayer;
let sapcbLayer;
let lm_ramsarLayer;
let rn_ramsarLayer;



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
  
  // Cargar y configurar la capa de aicas
  try {
    const geojsonScript = document.getElementById('aicas_layer_geojson');
    if (geojsonScript && geojsonScript.textContent) {
      const aicasData = JSON.parse(geojsonScript.textContent);
      aicasdLayer = new google.maps.Data();
      aicasdLayer.addGeoJson(aicasData);
      aicasdLayer.setStyle({
        fillColor: '#0077b6', // Un azul distintivo
        strokeWeight: 1.5,
        strokeColor: '#48494b',
        fillOpacity: 0.4
      });
    }
  } catch (e) {
    console.error("Error al cargar o procesar la capa GeoJSON de Áreas de Importancia para la Conservación de las Aves:", e);
  }
  
   // Cargar y configurar la capa de sistema_arrecifal_tamaulipas
  try {
    const geojsonScript = document.getElementById('sistema_arrecifal_tamaulipas_layer_geojson');
    if (geojsonScript && geojsonScript.textContent) {
      const sistema_arrecifal_tamaulipasData = JSON.parse(geojsonScript.textContent);
      sistema_arrecifal_tamaulipasLayer = new google.maps.Data();
      sistema_arrecifal_tamaulipasLayer.addGeoJson(sistema_arrecifal_tamaulipasData);
      sistema_arrecifal_tamaulipasLayer.setStyle({
        fillColor: '#ecb311', // Un amarillo distintivo
        strokeWeight: 1.5,
        strokeColor: '#48494b',
        fillOpacity: 0.4
      });
    }
  } catch (e) {
    console.error("Error al cargar o procesar la capa GeoJSON de Sistema Arrecifal Artificial:", e);
  } 
  
     // Cargar y configurar la capa de region terrestre prioritaria
  try {
    const geojsonScript = document.getElementById('rtp_layer_geojson');
    if (geojsonScript && geojsonScript.textContent) {
      const rtpData = JSON.parse(geojsonScript.textContent);
      rtpLayer = new google.maps.Data();
      rtpLayer.addGeoJson(rtpData);
      rtpLayer.setStyle({
        fillColor: '#09c260', // Un verde distintivo
        strokeWeight: 1.5,
        strokeColor: '#48494b',
        fillOpacity: 0.4
      });
    }
  } catch (e) {
    console.error("Error al cargar o procesar la capa GeoJSON de Regiones Terrestres Prioritarias:", e);
  } 
 
      // Cargar y configurar la capa de region marina prioritaria
  try {
    const geojsonScript = document.getElementById('rmp_layer_geojson');
    if (geojsonScript && geojsonScript.textContent) {
      const rmpData = JSON.parse(geojsonScript.textContent);
      rmpLayer = new google.maps.Data();
      rmpLayer.addGeoJson(rmpData);
      rmpLayer.setStyle({
        fillColor: '#0925c2', // Un azul distintivo
        strokeWeight: 1.5,
        strokeColor: '#48494b',
        fillOpacity: 0.4
      });
    }
  } catch (e) {
    console.error("Error al cargar o procesar la capa GeoJSON de Regiones Marinas Prioritarias:", e);
  } 
   
         // Cargar y configurar la capa de Sitio Ramsar Laguna Madre
  try {
    const geojsonScript = document.getElementById('lm_ramsar_layer_geojson');
    if (geojsonScript && geojsonScript.textContent) {
      const lm_ramsarData = JSON.parse(geojsonScript.textContent);
      lm_ramsarLayer = new google.maps.Data();
      lm_ramsarLayer.addGeoJson(lm_ramsarData);
      lm_ramsarLayer.setStyle({
        fillColor: '#02a8c2', // Un azul distintivo
        strokeWeight: 1.5,
        strokeColor: '#48494b',
        fillOpacity: 0.4
      });
    }
  } catch (e) {
    console.error("Error al cargar o procesar la capa GeoJSON de Sitio Ramsar Laguna Madre:", e);
  }
  
           // Cargar y configurar la capa de Sitio Ramsar Rancho Nuevo
  try {
    const geojsonScript = document.getElementById('rn_ramsar_layer_geojson');
    if (geojsonScript && geojsonScript.textContent) {
      const rn_ramsarData = JSON.parse(geojsonScript.textContent);
      rn_ramsarLayer = new google.maps.Data();
      rn_ramsarLayer.addGeoJson(rn_ramsarData);
      rn_ramsarLayer.setStyle({
        fillColor: '#0077b6', // Un azul distintivo
        strokeWeight: 1.5,
        strokeColor: '#48494b',
        fillOpacity: 0.4
      });
    }
  } catch (e) {
    console.error("Error al cargar o procesar la capa GeoJSON de Sitio Ramsar Rancho Nuevo:", e);
  } 
}

           // Cargar y configurar la capa de Hidrología
  try {
    const geojsonScript = document.getElementById('hidro_tam_nl_coa_layer_geojson');
    if (geojsonScript && geojsonScript.textContent) {
      const hidro_tam_nl_coaData = JSON.parse(geojsonScript.textContent);
      hidro_tam_nl_coaLayer = new google.maps.Data();
      hidro_tam_nl_coaLayer.addGeoJson(uso_suelo_matData);
      hidro_tam_nl_coaLayer.setStyle({
        fillColor: '#0ceac8', // Un azul distintivo
        strokeWeight: 1.5,
        strokeColor: '#48494b',
        fillOpacity: 0.4
      });
    }
  } catch (e) {
    console.error("Error al cargar o procesar la capa GeoJSON de Hidrología:", e);
  } 
}

           // Cargar y configurar la capa de buff1_300F_50m
  try {
    const geojsonScript = document.getElementById('buff1_300F_50m_layer_geojson');
    if (geojsonScript && geojsonScript.textContent) {
      const buff1_300F_50mData = JSON.parse(geojsonScript.textContent);
      buff1_300F_50mLayer = new google.maps.Data();
      buff1_300F_50mLayer.addGeoJson(buff1_300F_50mData);
      buff1_300F_50mLayer.setStyle({
        fillColor: '#dc140a', // Un rojo distintivo
        strokeWeight: 1.5,
        strokeColor: '#48494b',
        fillOpacity: 0.4
      });
    }
  } catch (e) {
    console.error("Error al cargar o procesar la capa GeoJSON de Columna de calor (150°C - 0.05 km):", e);
  } 
}

           // Cargar y configurar la capa de buff1_212F_482m
  try {
    const geojsonScript = document.getElementById('buff1_212F_482m_layer_geojson');
    if (geojsonScript && geojsonScript.textContent) {
      const buff1_212F_482mData = JSON.parse(geojsonScript.textContent);
      buff1_212F_482mLayer = new google.maps.Data();
      buff1_212F_482mLayer.addGeoJson(buff1_212F_482mData);
      buff1_212F_482mLayer.setStyle({
        fillColor: '#ee9606', // Un naranja distintivo
        strokeWeight: 1.5,
        strokeColor: '#48494b',
        fillOpacity: 0.4
      });
    }
  } catch (e) {
    console.error("Error al cargar o procesar la capa GeoJSON de Columna de calor (100°C - 0.482 km):", e);
  } 
}

           // Cargar y configurar la capa de buff1_90F_965m
  try {
    const geojsonScript = document.getElementById('buff1_90F_965m_layer_geojson');
    if (geojsonScript && geojsonScript.textContent) {
      const buff1_90F_965mData = JSON.parse(geojsonScript.textContent);
      buff1_90F_965mLayer = new google.maps.Data();
      buff1_90F_965mLayer.addGeoJson(buff1_90F_965mData);
      buff1_90F_965mLayer.setStyle({
        fillColor: '#f3e61e', // Un amarillo distintivo
        strokeWeight: 1.5,
        strokeColor: '#48494b',
        fillOpacity: 0.4
      });
    }
  } catch (e) {
    console.error("Error al cargar o procesar la capa GeoJSON de Columna de calor (32.22°C - 0.965 km):", e);
  } 
}

           // Cargar y configurar la capa de buff2_140db_804m
  try {
    const geojsonScript = document.getElementById('buff2_140db_804m_layer_geojson');
    if (geojsonScript && geojsonScript.textContent) {
      const buff2_140db_804mData = JSON.parse(geojsonScript.textContent);
      buff2_140db_804mLayer = new google.maps.Data();
      buff2_140db_804mLayer.addGeoJson(buff2_140db_804mData);
      buff2_140db_804mLayer.setStyle({
        fillColor: '#dc140a', // Un rojo distintivo
        strokeWeight: 1.5,
        strokeColor: '#48494b',
        fillOpacity: 0.4
      });
    }
  } catch (e) {
    console.error("Error al cargar o procesar la capa GeoJSON de Contorno de ruido (140 dB - 0.804 km):", e);
  } 
}

           // Cargar y configurar la capa de buff2_130db_5471m
  try {
    const geojsonScript = document.getElementById('buff2_130db_5471m_layer_geojson');
    if (geojsonScript && geojsonScript.textContent) {
      const buff2_130db_5471mData = JSON.parse(geojsonScript.textContent);
      buff2_130db_5471mLayer = new google.maps.Data();
      buff2_130db_5471mLayer.addGeoJson(buff2_130db_5471mData);
      buff2_130db_5471mLayer.setStyle({
        fillColor: '#ee9606', // Un naranja distintivo
        strokeWeight: 1.5,
        strokeColor: '#48494b',
        fillOpacity: 0.4
      });
    }
  } catch (e) {
    console.error("Error al cargar o procesar la capa GeoJSON de Contorno de ruido (130 dB - 5.47 km):", e);
  } 
}

           // Cargar y configurar la capa de buff2_120db_15288m
  try {
    const geojsonScript = document.getElementById('buff2_120db_15288m_layer_geojson');
    if (geojsonScript && geojsonScript.textContent) {
      const buff2_120db_15288mData = JSON.parse(geojsonScript.textContent);
      buff2_120db_15288mLayer = new google.maps.Data();
      buff2_120db_15288mLayer.addGeoJson(buff2_120db_15288mData);
      buff2_120db_15288mLayer.setStyle({
        fillColor: '#f3e61e', // Un amarillo distintivo
        strokeWeight: 1.5,
        strokeColor: '#48494b',
        fillOpacity: 0.4
      });
    }
  } catch (e) {
    console.error("Error al cargar o procesar la capa GeoJSON de Contorno de ruido (120 dB - 15.29 km):", e);
  } 
}

           // Cargar y configurar la capa de buff2_111db_36210m
  try {
    const geojsonScript = document.getElementById('buff2_111db_36210m_layer_geojson');
    if (geojsonScript && geojsonScript.textContent) {
      const buff2_111db_36210mData = JSON.parse(geojsonScript.textContent);
      buff2_111db_36210mLayer = new google.maps.Data();
      buff2_111db_36210mLayer.addGeoJson(buff2_111db_36210mData);
      buff2_111db_36210mLayer.setStyle({
        fillColor: '#73df78', // Un verde distintivo
        strokeWeight: 1.5,
        strokeColor: '#48494b',
        fillOpacity: 0.4
      });
    }
  } catch (e) {
    console.error("Error al cargar o procesar la capa GeoJSON de Contorno de ruido (111 dB - 36.21 km):", e);
  } 
}

          // Cargar y configurar la capa de buff3_6psf_16093m
  try {
    const geojsonScript = document.getElementById('buff3_6psf_16093m_layer_geojson');
    if (geojsonScript && geojsonScript.textContent) {
      const buff3_6psf_16093mData = JSON.parse(geojsonScript.textContent);
      buff3_6psf_16093mLayer = new google.maps.Data();
      buff3_6psf_16093mLayer.addGeoJson(buff3_6psf_16093mData);
      buff3_6psf_16093mLayer.setStyle({
        fillColor: '#dc140a', // Un rojo distintivo
        strokeWeight: 1.5,
        strokeColor: '#48494b',
        fillOpacity: 0.4
      });
    }
  } catch (e) {
    console.error("Error al cargar o procesar la capa GeoJSON de Explosiones sónicas (6 psf - 16.09 km):", e);
  } 
}

           // Cargar y configurar la capa de buff3_4psf_24140m
  try {
    const geojsonScript = document.getElementById('buff3_4psf_24140m_layer_geojson');
    if (geojsonScript && geojsonScript.textContent) {
      const buff3_4psf_24140mData = JSON.parse(geojsonScript.textContent);
      buff3_4psf_24140mLayer = new google.maps.Data();
      buff3_4psf_24140mLayer.addGeoJson(buff3_4psf_24140mData);
      buff3_4psf_24140mLayer.setStyle({
        fillColor: '#ee9606', // Un naranja distintivo
        strokeWeight: 1.5,
        strokeColor: '#48494b',
        fillOpacity: 0.4
      });
    }
  } catch (e) {
    console.error("Error al cargar o procesar la capa GeoJSON de Explosiones sónicas (4 psf - 24.14 km):", e);
  } 
}

           // Cargar y configurar la capa de buff3_2psf_43452m
  try {
    const geojsonScript = document.getElementById('buff3_2psf_43452m_layer_geojson');
    if (geojsonScript && geojsonScript.textContent) {
      const buff3_2psf_43452mData = JSON.parse(geojsonScript.textContent);
      buff3_2psf_43452mLayer = new google.maps.Data();
      buff3_2psf_43452mLayer.addGeoJson(buff3_2psf_43452mData);
      buff3_2psf_43452mLayer.setStyle({
        fillColor: '#73df78', // Un amarillo distintivo
        strokeWeight: 1.5,
        strokeColor: '#48494b',
        fillOpacity: 0.4
      });
    }
  } catch (e) {
    console.error("Error al cargar o procesar la capa GeoJSON de Explosiones sónicas (2 psf - 43.45 km):", e);
  } 
} 

           // Cargar y configurar la capa de buff3_1psff_45061m
  try {
    const geojsonScript = document.getElementById('buff3_1psff_45061m_layer_geojson');
    if (geojsonScript && geojsonScript.textContent) {
      const buff3_1psff_45061mData = JSON.parse(geojsonScript.textContent);
      buff3_1psff_45061mLayer = new google.maps.Data();
      buff3_1psff_45061mLayer.addGeoJson(buff3_1psff_45061mData);
      buff3_1psff_45061mLayer.setStyle({
        fillColor: '#73df78', // Un verde distintivo
        strokeWeight: 1.5,
        strokeColor: '#48494b',
        fillOpacity: 0.4
      });
    }
  } catch (e) {
    console.error("Error al cargar o procesar la capa GeoJSON de Explosiones sónicas (1 psf - 45.06 km):", e);
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

// Función para mostrar/ocultar la capa aicas
function toggleaicasLayer(show) {
  if (aicasLayer) {
    aicasLayer.setMap(show ? map : null);
  }
}

// Función para mostrar/ocultar la capa sistema_arrecifal_tamaulipas
function togglesistema_arrecifal_tamaulipasLayer(show) {
  if (sistema_arrecifal_tamaulipasLayer) {
    sistema_arrecifal_tamaulipasLayer.setMap(show ? map : null);
  }
}

// Función para mostrar/ocultar la capa rtp
function togglertpLayer(show) {
  if (rtpLayer) {
    rtpLayer.setMap(show ? map : null);
  }
}

// Función para mostrar/ocultar la capa rmp
function togglermpLayer(show) {
  if (rmpLayer) {
    rmpLayer.setMap(show ? map : null);
  }
}

// Función para mostrar/ocultar la capa lm_ramsar
function togglelmramsarLayer(show) {
  if (lm_ramsarLayer) {
    lm_ramsarLayer.setMap(show ? map : null);
  }
}

// Función para mostrar/ocultar la capa rn_ramsar
function togglernramsarLayer(show) {
  if (rn_ramsarLayer) {
    rn_ramsarLayer.setMap(show ? map : null);
  }
}

// Función para mostrar/ocultar la capa hidro_tam_nl_coa
function togglehidro_tam_nl_coaLayer(show) {
  if (hidro_tam_nl_coaLayer) {
    hidro_tam_nl_coaLayer.setMap(show ? map : null);
  }
}

// Función para mostrar/ocultar la capa buff1_300F_50m
function togglebuff1_300F_50mLayer(show) {
  if (buff1_300F_50mLayer) {
    buff1_300F_50mLayer.setMap(show ? map : null);
  }
}

// Función para mostrar/ocultar la capa buff1_212F_482m
function togglebuff1_212F_482mLayer(show) {
  if (buff1_212F_482mLayer) {
    buff1_212F_482mLayer.setMap(show ? map : null);
  }
}

// Función para mostrar/ocultar la capa buff1_90F_965m
function togglebuff1_90F_965mLayer(show) {
  if (buff1_90F_965mLayer) {
    buff1_90F_965mLayer.setMap(show ? map : null);
  }
}

// Función para mostrar/ocultar la capa buff2_140db_804m
function togglebuff2_140db_804mLayer(show) {
  if (buff2_140db_804mLayer) {
    buff2_140db_804mLayer.setMap(show ? map : null);
  }
}

// Función para mostrar/ocultar la capa buff2_130db_5471m
function togglebuff2_130db_5471mLayer(show) {
  if (buff2_130db_5471mLayer) {
    buff2_130db_5471mLayer.setMap(show ? map : null);
  }
}

// Función para mostrar/ocultar la capa buff2_120db_15288m
function togglebuff2_120db_15288mLayer(show) {
  if (buff2_120db_15288mLayer) {
    buff2_120db_15288mLayer.setMap(show ? map : null);
  }
}

// Función para mostrar/ocultar la capa buff2_111db_36210m
function togglebuff2_111db_36210mLayer(show) {
  if (buff2_111db_36210mLayer) {
    buff2_111db_36210mLayer.setMap(show ? map : null);
  }
}

// Función para mostrar/ocultar la capa buff3_6psf_16093m
function togglebuff3_6psf_16093mLayer(show) {
  if (buff3_6psf_16093mLayer) {
    buff3_6psf_16093mLayer.setMap(show ? map : null);
  }
}

// Función para mostrar/ocultar la capa buff3_4psf_24140m
function togglebuff3_4psf_24140mLayer(show) {
  if (buff3_4psf_24140mLayer) {
    buff3_4psf_24140mLayer.setMap(show ? map : null);
  }
}

// Función para mostrar/ocultar la capa buff3_2psf_43452m
function togglebuff3_2psf_43452mLayer(show) {
  if (buff3_2psf_43452mLayer) {
    buff3_2psf_43452mLayer.setMap(show ? map : null);
  }
}

// Función para mostrar/ocultar la capa buff3_1psff_45061m
function togglebuff3_1psff_45061mLayer(show) {
  if (buff3_1psff_45061mLayer) {
    buff3_1psff_45061mLayer.setMap(show ? map : null);
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