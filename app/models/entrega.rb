# -*- encoding : utf-8 -*-
class Entrega < ActiveRecord::Base
	set_primary_key :id
	validates :nombre ,:fecha_entrega,:numero_max_integrantes,:fecha_tope,:archivo_tamano_max,:archivo_formato,:limite_versiones ,:presence => true
	validates :nombre , :length => {:minimum => 3}
end
