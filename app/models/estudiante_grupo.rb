# -*- encoding : utf-8 -*-
class EstudianteGrupo < ActiveRecord::Base
	set_primary_keys :estudiante_cedula , :grupo_nro , :entrega_id
	belongs_to :estudiante , :foreign_key => :estudiante_cedula
	belongs_to :grupo , :foreign_key => [:grupo_nro , :entrega_id]
	
end
