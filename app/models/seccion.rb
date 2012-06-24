# -*- encoding : utf-8 -*-
class Seccion < ActiveRecord::Base
	set_primary_keys :nombre , :materia_id
	belongs_to :materia
	
  
#Identico be.each do 11longs_to
# 	def materia 
# 	   Materia.where(:id => materia_id).first#Primero del arreglo
# 	   #Una sola materia , se necesita recorrer si hay varias
# 	end
	
end
