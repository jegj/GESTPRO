# -*- encoding : utf-8 -*-
class Seccion < ActiveRecord::Base
	set_primary_keys :nombre , :materia_id
	belongs_to :materia
	
  
#Identico be.each do 11longs_to
# 	def materia 
# 	   Materia.where(:id => materia_id).first#Primero del arreglo
# 	   #Una sola materia , se necesita recorrer si hay varias
# 	end

	def self.secciones_nombres(materia_id)	
		Seccion.where(:materia_id => materia_id)
	end

	def self.eliminar_seccion(sec_nombre,materia_id)
		secc=Seccion.where(:nombre=>sec_nombre,:materia_id=>materia_id).first
		secc.delete
	end
end
