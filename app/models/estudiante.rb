# -*- encoding : utf-8 -*-
class Estudiante < ActiveRecord::Base
	set_primary_key :usuario_cedula
	belongs_to :usuario , :foreign_key => :usuario_cedula
	def materias  
	  EstudianteSeccion.where(:estudiante_cedula => usuario_cedula).collect{ |x| x.materia} #Collect sustituye el arreglo q retorno por lo q le especifico despues de el. 
	end
end
