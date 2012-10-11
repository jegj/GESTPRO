# -*- encoding : utf-8 -*-
class EntregaArchivo < ActiveRecord::Base
	set_primary_key :entrega_id
	belongs_to :entrega

	def self.borrar_archivo(entrega_id)
		archivo=EntregaArchivo.where(:entrega_id=>entrega_id).first
		archivo.delete
	end

	def self.descargar_enunciado(entrega_id)
		EntregaArchivo.where(:entrega_id=>entrega_id).first
	end
end
