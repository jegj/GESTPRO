# -*- encoding : utf-8 -*-
class EstudianteSeccion < ActiveRecord::Base
	set_primary_keys :estudiante_cedula , :seccion_nombre , :materia_id
	belongs_to :estudiante , :foreign_key => :estudiante_cedula
	belongs_to :seccion  , :foreign_key => :seccion_nombre
	belongs_to :materia , :foreign_key => :materia_id
	
# 	def estudiante
# 	  Estudiante.where(:usuario_cedula => estudiante_cedula).first
# 	end
	

	
end
