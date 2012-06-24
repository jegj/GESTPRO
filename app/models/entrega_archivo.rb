# -*- encoding : utf-8 -*-
class EntregaArchivo < ActiveRecord::Base
	set_primary_key :entrega_id
	belongs_to :entrega
end
