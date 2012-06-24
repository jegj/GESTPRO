# -*- encoding : utf-8 -*-
class EntregableArchivo < ActiveRecord::Base
	set_primary_keys :grupo_nro , :entrega_id
	belongs_to :entregable  , :foreign_key =>[:grupo_nro,:entrega_id]
end
