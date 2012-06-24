# -*- encoding : utf-8 -*-
class Usuario < ActiveRecord::Base
	set_primary_key :cedula
	has_one :docente , :foreign_key => :cedula
	has_one :estudiante , :foreign_key => :cedula
	has_one :administrador, :foreign_key => :cedula

	validates :nombres , :apellidos , :cedula ,:correo,:clave,:presence => true
	validates :clave, :confirmation => true
	validates :nombres , :length => {:minimum => 3}
	validates :clave , :length => {:minimum => 5}
	

	def nombre_completo
	  #return nombres + " " + apellidos  PUEDE SER HACKEADO
	  "#{nombres} #{apellidos}" #string interpolado(php)
	end
	
	def descripcion
	  "#{cedula}-#{nombres} #{apellidos}"
	end

	def self.buscar_usuario(cedula)
			Usuario.where(:cedula =>cedula).first
	end
	
	#metodo a distancia/estatico
	#where retorna un arreglo
	def  self.autenticar(cedula,clave)
	   Usuario.where(:cedula => cedula, :clave => clave).first 	
	end
	
	def es_estudiante?
	  Estudiante.where(:usuario_cedula => cedula).first
	end
	
	def es_docente?
	  Docente.where(:usuario_cedula => cedula).first
	end
	
	def es_administrador?
	  Administrador.where(:usuario_cedula => cedula).first
	end
	
	def rol
	  
	  if ret=es_estudiante?
	    return ret
	  end
	  
	  if ret=es_docente?
	    return ret
	  end
	  
	  if ret=es_administrador?
	    return ret
	  end
      
	end
end
