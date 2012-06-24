  # Place all the behaviors and hooks related to the matching controller here.
  # All this logic will automatically be available in application.js.
  # You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
  $ ->
      $('#listado-materias').accordion
            autoHeight: false,
            navigation: true,
            collapsible: true
        
  $ ->
      $('#listado_entregable').accordion  
            autoHeight: false,
            navigation: true,
            collapsible: true
          
  $ ->
   		$('#entrega_seccion_materia_id').change -> 
   			$('#spinner').show()
   			materia_id=$(this).attr('value')
   			$.ajax
   				url: 'ajax_buscar_seccion?materia_id='+materia_id,
   				success: (data) -> 
   					$('#secciones').html data
						$('#spinner').hide()

  $ ->
      $('.fecha').datepicker
        showOn: "button",
        buttonImage: "/assets/imagedate.gif",
        buttonImageOnly: true
        dateFormat: "yy-mm-dd"
        
   					
      