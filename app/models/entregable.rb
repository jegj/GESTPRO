# -*- encoding : utf-8 -*-
class Entregable < ActiveRecord::Base
	set_primary_keys :grupo_nro , :entrega_id
	belongs_to :grupo  , :foreign_key => [:grupo_nro,:entrega_id]
	validates :grupo ,:presence => true	
	# belongs_to :estudiante_entrego , #METODO
	# 	   :foreign_key => :estudiante_cedula_entrego ,
	# 	   :class => "Estudiante"#NOMBRE DE LA TABLA

end
