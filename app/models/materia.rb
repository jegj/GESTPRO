# -*- encoding : utf-8 -*-
class Materia < ActiveRecord::Base
	set_primary_key :id
	
	#Identico a has_many
	def secciones
	   Seccion.where(:materia_id => id)
	end
	
  def entregas
    EntregaSeccion.where(:materia_id => id).collect{|x| x.entrega}.uniq
    #uniq , metodo de arreglos quita las entradas repetidas
  end

  def self.buscar_materia(id)
  	Materia.where(:id => id).first.nombre
  end

	has_many :seccion
end

