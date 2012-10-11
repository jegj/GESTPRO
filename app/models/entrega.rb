# -*- encoding : utf-8 -*-
class Entrega < ActiveRecord::Base
	set_primary_key :id
	validates :nombre ,:fecha_entrega,:numero_max_integrantes,:fecha_tope,:archivo_tamano_max,:archivo_formato,:limite_versiones ,:presence => true
	validates :nombre , :length => {:minimum => 3}
	validate :validar_fecha_entrega,:validar_fecha_actual

def validar_fecha_entrega
	if fecha_entrega &&fecha_tope
		errors.add(:fecha_tope,"Verifique la fecha de entrega")if fecha_entrega>fecha_tope
	end
end

def validar_fecha_actual
	if fecha_entrega
		errors.add(:fecha_entrega,"La fecha debe ser mayor que la actual") if fecha_entrega<Date.today
	end

	if fecha_tope
		errors.add(:fecha_tope,"La fecha debe ser mayor que la actual") if fecha_tope<Date.today
	end		
end

def self.limite(id)
	Entrega.find(id).limite_versiones
end


def self.obtener_nombre(id)
	Entrega.where(:id => id).first.nombre
end

def self.buscar_entrega(id)
	Entrega.where(:id =>id).first
end

def self.obtener_formato(id)
	Entrega.where(:id=>id).first.archivo_formato
end

end
