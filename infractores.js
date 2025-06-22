$(document).on("click", ".info-btn-sanciones", function(e) {
  e.preventDefault();
  var nombre = $(this).data("nombre");
  
  // Enviar el dato a Shiny
  Shiny.onInputChange("info_infractor_sanciones", {
    nombre: nombre,
    nonce: Math.random() // Evita el almacenamiento en caché de eventos duplicados
  });
  
  // Cambiar a la pestaña correspondiente en Shiny y forzar el valor de la pestaña
  Shiny.setInputValue("cambiar_tab_sanciones", "Información individual sanciones", {priority: "event"});
});

$(document).on("click", ".info-btn-multas", function(e) {
  e.preventDefault();
  var nombre = $(this).data("nombre");
  
  // Enviar el dato a Shiny
  Shiny.onInputChange("info_infractor_multas", {
    nombre: nombre,
    nonce: Math.random() // Evita el almacenamiento en caché de eventos duplicados
  });
  
    // Cambiar a la pestaña correspondiente en Shiny
  Shiny.setInputValue("cambiar_tab_multas", "Información individual multas", {priority: "event"});
  
});