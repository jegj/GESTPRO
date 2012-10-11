# -*- encoding : utf-8 -*-
class Usuario < ActiveRecord::Base
	set_primary_key :cedula
	has_one :docente , :foreign_key => :cedula
	has_one :estudiante , :foreign_key => :cedula
	has_one :administrador, :foreign_key => :cedula

	validates :nombres , :apellidos , :cedula ,:correo,:presence => true
	validates :nombres , :length => {:minimum => 3}
	validates :correo,:email=>true
	validates :correo,:uniqueness=>true
	validates :cedula ,:uniqueness=>true
	validates :cedula ,:numericality => { :only_integer => true }
	

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
	
	def self.buscar_informacion(cedula)
			Usuario.where(:cedula =>cedula).first.descripcion
	end
	#metodo a distancia/estatico
	#where retorna un arreglo
	def  self.autenticar(cedula,clave)
	  # Usuario.where(:cedula => cedula, :clave => clave).first 	
	  # Usuario.where(["cedula = ? AND clave=MD5(?)",cedula,clave]).first
	  # version ruby
	   clave_digest=Digest::MD5.hexdigest(clave)
		 Usuario.where(:cedula => cedula, :clave => clave_digest).first 		  

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

	def self.informacion(ced)
		Usuario.where(:cedula => ced).first
	end

	def buscar_estudiante_materia
		estudiante_seccion=EstudianteSeccion.where(:estudiante_cedula=>cedula).collect{|x| x.materia_id}
	end

	def todos_roles()
		roles=Array.new
		if(ret=es_estudiante?)
			roles.push("Estudiante")
		end
		if(ret=es_administrador?)
			roles.push("Administrador")
		end
		if(ret=es_docente?)
			roles.push("Docente")
		end
		return roles
	end

	def score
		0
	end

end
