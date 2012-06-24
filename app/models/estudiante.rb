# -*- encoding : utf-8 -*-
class Estudiante < ActiveRecord::Base
	set_primary_key :usuario_cedula
	belongs_to :usuario , :foreign_key => :usuario_cedula
end
