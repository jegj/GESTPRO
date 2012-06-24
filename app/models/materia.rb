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
  def entrega_cedula (cedula)
  	seccion= EstudianteSeccion.where(:estudiante_cedula => cedula, :materia_id => id).first.seccion_nombre
  	EntregaSeccion.where(:materia_id => id, :seccion_nombre => seccion).collect{|x| x.entrega}.uniq

  end
  def self.buscar_materia(id)
  	Materia.where(:id => id).first.nombre
  end

	has_many :seccion
end

