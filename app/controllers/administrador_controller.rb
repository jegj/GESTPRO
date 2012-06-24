# -*- encoding : utf-8 -*-
class AdministradorController < ApplicationController
	before_filter :verificar_autenticado

	layout "application"

	 def comprobar_docente
	 	@titulo_pagina="Comprobar Docente"
	 end

	 def asignar_docente

	 	@titulo_pagina="Asignar Docente"

	 	unless params[:docente] && params[:docente][:cedula]
	 		flash[:mensaje2]="Faltan parametros"
      bitacora "Faltan parametros"
      redirect_to :action => "comprobar_docente"
      return
	 	end

	 	cedula=params[:docente][:cedula]

	 	if cedula.empty?
	 		flash[:mensaje2]="Debe introducir una cedula"
		 	redirect_to :action => "comprobar_docente"
	    return
	 	end

	 	@usr=Usuario.buscar_usuario(cedula)
	 	@materias=Materia.all

	 	if @usr !=nil
		 	if(@usr.es_estudiante? || @usr.es_administrador?)
		 		flash[:mensaje2]="El usuario debe ser Docente"
		 		redirect_to :action => "comprobar_docente"
	      return
		 	end
		end

	 end

	 def guardar_docente_entrega
	 	@titulo_pagina= "Asignar Docente"
 		
 		@materias=Materia.all

 		unless(params[:docente_materia] && params[:docente_materia][:materia_id])
		 		 	flash[:mensaje2]="Faltan parametros"
          bitacora "Faltan parametros"
          redirect_to :action => 'bienvenida',:controller =>'principal'		
          return
		end

		 if(params[:docente_cedula])
		 	@usr=Usuario.buscar_usuario(params[:docente_cedula])
		 	unless DocenteMateria.busca_docente_materia(params[:docente_cedula],params[:docente_materia][:materia_id]) 
			 	@docente_materia=DocenteMateria.new
			 	@docente_materia.docente_cedula=params[:docente_cedula]
			 	@docente_materia.materia_id=params[:docente_materia][:materia_id]
			 	if @docente_materia.save
			 		bitacora "Se asigno el docente con cedula #{@docente_materia.docente_cedula} a la materia con codigo #{@docente_materia.materia_id}"
			 		flash[:mensaje2]="Se asigno el Docente con exito"
					redirect_to :action => 'bienvenida',:controller =>'principal'		
					return
			 	else
			 		bitacora "Datos invalidos al asignar un docente a una materia"
			 		render :action => "asignar_docente"
			 	end
			else
				bitacora "Se trato de asignar un docente a una materia que ya tenia asignada"
				flash[:mensaje2] ="El Docente ya tiene asignado la materia"
				render :action =>"asignar_docente"
			end	
		 end
	 end

	 def guardar_crear_docente_entrega
	 	@titulo_pagina= "Asignar Docente" 		
 		@materias=Materia.all
 		@usr=nil

 		unless params[:usuario] && params[:usuario][:nombres] && params[:usuario][:apellidos] && params[:usuario][:clave] && params[:usuario][:correo]
 			flash[:mensaje2]="Faltan parametros"
			bitacora "Faltan parametros"
      redirect_to :action => 'bienvenida',:controller =>'principal'		
      return
 		end

 		if params[:usuario]
 			unless Usuario.buscar_usuario(params[:usuario][:cedula])
		 		@usuario=Usuario.new
		 		@usuario.cedula=params[:usuario][:cedula]
		 		@usuario.nombres=params[:usuario][:nombres]
		 		@usuario.apellidos=params[:usuario][:apellidos]
		 		@usuario.clave =params[:usuario][:clave]
		 		@usuario.correo=params[:usuario][:correo]

		 		if params[:usuario][:clave] != params[:usuario][:clave_confirmation]
			 		@usuario.errors[:base]<<"Las claves no coinciden."
		 			render :action => "asignar_docente"
		 			return	
 				end

		 		if params[:docente_materia][:materia_id].empty?
		 			@usuario.errors[:base]<<"No se especifico la materia."
		 			render :action => "asignar_docente"
		 			return
		 		end

		 		if @usuario.save
		 				docente=Docente.new
		 				docente.usuario_cedula=@usuario.cedula
		 				docente.save
		 				docente_materia =DocenteMateria.new
		 				docente_materia.docente_cedula=@usuario.cedula
		 				docente_materia.materia_id=params[:docente_materia][:materia_id] 
		 				docente_materia.save
			 			bitacora "Se asigno el docente con cedula #{@usuario.cedula} a la materia con codigo #{docente_materia.materia_id}"
						flash[:mensaje2]="Se asigno el Docente con exito"
						redirect_to :action => 'bienvenida',:controller =>'principal'		
						return
		 		else
					bitacora "Datos invalidos al asignar un docente a una materia"
				 	render :action => "asignar_docente"	 			
		 		end
		 	else
		 		bitacora "El docente ya existe"
		 		flash[:mensaje2]="El Docente ya existe"
		 		render :action => "asignar_docente"
		 	end
	 	end 		

	 end
	 
end