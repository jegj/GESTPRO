	
class Procesador
	def self.analizar_excel(materia, ruta)	
		documento=Excel.new(ruta)
		documento.default_sheet = documento.sheets.first
		respuesta =Hash.new 
		# puts documento.cell(5,1)
		# .cell (fila,columna)
		celda_seccion=documento.cell(5,1)
		seccion=celda_seccion[9..celda_seccion.size]
		celda_codigo_nombre=documento.cell(4,1)
		codigo_materia=celda_codigo_nombre[10..13]		
		nombre_materia=celda_codigo_nombre[16..celda_codigo_nombre.size]		

		if(codigo_materia!=materia)
			respuesta["correcto"]=false
			respuesta["mensaje"]="El archivo pertenece a #{nombre_materia
			}"
			return respuesta
		end

		
		unless Seccion.where(:nombre => seccion, :materia_id => materia).first
			sec=Seccion.new
			sec.nombre=seccion
			sec.materia_id=materia
			sec.save
			respuesta["correcto"]=true
			respuesta["mensaje"]="Se creo una nueva seccion"
			indice=8 			
			estudiantes=Array.new
			while documento.cell(indice,1) do
				indice=indice+1
			end

			final=indice-1
			indice=8

			(indice..final).each {|mi_indice|
				licenciatura=documento.cell(mi_indice,2)
				cedula=documento.cell(mi_indice,3).to_i
				nombre_completo=documento.cell(mi_indice,4)
				correo=documento.cell(mi_indice,5)				
				estado=documento.cell(mi_indice,6)

				if !estado.eql?("RETIRADO")	
					unless licenciatura.eql?("COMPUTACION")			
						respuesta["correcto"]=false
						respuesta["mensaje"]="Uno de los alumnos no pertenece a  Computacion"				
						Seccion.eliminar_seccion(sec.nombre,sec.materia_id)				
						return respuesta 
					end

					unless user=Usuario.buscar_usuario(cedula)
						respuesta["correcto"]=false
						respuesta["mensaje"]="El alumno #{cedula}-#{nombre_completo} no esta registrado en el sistema"				
						Seccion.eliminar_seccion(sec.nombre,sec.materia_id)				
						return respuesta 
					end

					unless user.es_estudiante?
						respuesta["correcto"]=false
						respuesta["mensaje"]="El alumno #{cedula}-#{nombre_completo} no es Estudiante"				
						Seccion.eliminar_seccion(sec.nombre,sec.materia_id)				
						return respuesta 
					end

					if EstudianteSeccion.numero_secciones(sec.materia_id,cedula)>=1
						respuesta["correcto"]=false
						respuesta["mensaje"]="El alumno #{cedula}-#{nombre_completo} ya se encuentra en otra seccion de la materia"				
						Seccion.eliminar_seccion(sec.nombre,sec.materia_id)				
						return respuesta
					end
					estudiantes.push(cedula)
				end
			}
			respuesta["seccion"]=sec.nombre
			respuesta["estudiantes"]=estudiantes
			return respuesta
		end


		respuesta["correcto"]=false
		respuesta["mensaje"]="La seccion ya se encuentra cargada"
		return respuesta
	end
end