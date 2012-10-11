# -*- encoding : utf-8 -*-
class Materia < ActiveRecord::Base
	set_primary_key :id
  validates :id,:nombre ,:presence=>true	
  validates :id ,:numericality => { :only_integer => true }
  validates :id ,:uniqueness=>true
	#Identico a has_many
	def secciones
	   Seccion.where(:materia_id => id)
	end

  def descripcion
    "#{id}-#{nombre}"
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

  def self.existe_materia?(id)
    Materia.where(:id => id).first
  end

	has_many :seccion
end

