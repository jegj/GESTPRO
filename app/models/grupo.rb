# -*- encoding : utf-8 -*-
class Grupo < ActiveRecord::Base
	set_primary_keys :nro , :entrega_id
	belongs_to :entrega
end
