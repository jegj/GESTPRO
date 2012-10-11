# -*- encoding : utf-8 -*-
class Estudiante < ActiveRecord::Base
	set_primary_key :usuario_cedula
	belongs_to :usuario , :foreign_key => :usuario_cedula

	def materias  
	  EstudianteSeccion.where(:estudiante_cedula => usuario_cedula).collect{ |x| x.materia} #Collect sustituye el arreglo q retorno por lo q le especifico despues de el. 
	end

	def self.buscar_estudiante(cedula)
		Estudiante.where(:usuario_cedula => cedula)
	end
	def self.cursa(cedula,materia,seccion)
		EstudianteSeccion.where(:estudiante_cedula => cedula, :materia_id => materia,:seccion_nombre => seccion)
	end

end
