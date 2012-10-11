# -*- encoding : utf-8 -*-
class EntregaSeccion < ActiveRecord::Base
	set_primary_keys :entrega_id , :seccion_nombre , :materia_id
	belongs_to :entrega
	belongs_to :seccion ,:foreign_key =>[:seccion_nombre,:materia_id]

	def self.buscar_materia(entrega)
		materia_id=EntregaSeccion.where(:entrega_id => entrega).first.materia_id
		Materia.buscar_materia(materia_id)
	end

	def self.buscar_materia_id(entrega_id)
		materia_id=EntregaSeccion.where(:entrega_id => entrega_id).first.materia_id		
	end

	def self.buscar_secciones(entrega_id)
		EntregaSeccion.where(:entrega_id => entrega_id)
	end 

	def self.obtener_materia(entrega_id)
		materia_id=EntregaSeccion.where(:entrega_id => entrega_id).first.materia_id
		Materia.where(:id=>materia_id).first
	end


	def self.eliminar_entrega_seccion(entrega_id)
		entrega_seccion=EntregaSeccion.where(:entrega_id => entrega_id)
		entrega_seccion.each do |fila_entrega_seccion|
			fila_entrega_seccion.delete
		end
	end	

	def self.existe_entrega_seccion(entrega_id,seccion_nombre,materia_id)
			EntregaSeccion.where(:entrega_id=>entrega_id,:seccion_nombre=>seccion_nombre,:materia_id=>materia_id).first
	end

	

end
