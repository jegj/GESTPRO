# -*- encoding : utf-8 -*-
class EstudianteSeccion < ActiveRecord::Base
	set_primary_keys :estudiante_cedula , :seccion_nombre , :materia_id
	belongs_to :estudiante , :foreign_key => :estudiante_cedula
	belongs_to :seccion  , :foreign_key => :seccion_nombre
	belongs_to :materia , :foreign_key => :materia_id
	
# 	def estudiante
# 	  Estudiante.where(:usuario_cedula => estudiante_cedula).first
# 	end
	
	def self.buscar_seccion(materia_id,cedula)	
		EstudianteSeccion.where(:estudiante_cedula=>cedula,:materia_id=>materia_id).first
	end

	def self.numero_secciones(materia_id,cedula)
		EstudianteSeccion.where(:estudiante_cedula=>cedula,:materia_id=>materia_id).count
	end

	def self.buscar_estudiante_seccion(materia_id,nombre_seccion,cedula)
		EstudianteSeccion.where(:estudiante_cedula=>cedula,:materia_id=>materia_id,:seccion_nombre=>nombre_seccion).first
	end

	def self.obtener_estudiantes(materia_id)
		EstudianteSeccion.where(:materia_id=>materia_id)
	end
	
end
