# -*- encoding : utf-8 -*-
class EntregaSeccion < ActiveRecord::Base
	set_primary_keys :entrega_id , :seccion_nombre , :materia_id
	belongs_to :entrega
	belongs_to :seccion ,:foreign_key =>[:seccion_nombre,:materia_id]

	def self.buscar_materia(entrega)
		materia_id=EntregaSeccion.where(:entrega_id => entrega).first.materia_id
		Materia.buscar_materia(materia_id)
	end
end
