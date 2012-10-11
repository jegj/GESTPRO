# -*- encoding : utf-8 -*-
class AdministradorController < ApplicationController
	before_filter :verificar_autenticado
	before_filter :verificar_admin

	layout "application"

 def verificar_admin
	  unless session[:usuario].es_administrador?
	    bitacora "Intento de accceso sin ser administrador"
	    flash[:error2]="Debe ser Administrador para acceder a estas opciones"
	    redirect_to :action => "bienvenida" , :controller => "principal"
	    return false
	  end
 end

 def bienvenida
  redirect_to :action=>"bienvenida",:controller=>"principal"
  return
 end	

 def listar_docentes
 	@titulo_pagina="Docentes"
 	@docentes=Docente.all
 end

 def eliminar_materia
 	@titulo_pagina="Eliminar Materia"
 	@materias=Materia.all
 end

 def modificar_usuario
 	@titulo_pagina="Modificar Usuario"
 end

 def registrar_estudiante
 	@titulo_pagina="Registrar Estudiante"
 end

 def eliminar_usuario
 	@titulo_pagina="Eliminar Usuario"
 end

 def comprobar_docente
 	@titulo_pagina="Comprobar Docente"
 end

 def desasignar_docentedes
 	@titulo_pagina="Desasignar Docente"
 end

 def agregar_materia
 	@titulo_pagina="Agregar Materia"
 end

 def listar_materias
 	@titulo_pagina="Materias"
 	@materias=Materia.all
 end


 def asignar_docente

 	@titulo_pagina="Asignar Docente"

 	unless params[:docente] && params[:docente][:cedula]
	  flash[:error2]="Faltan parametros"
      bitacora "Faltan parametros"
      redirect_to :action => "comprobar_docente"
      return
 	end

 	cedula=params[:docente][:cedula]

 	if cedula.empty?
 		flash[:error2]="Debe introducir una cedula"
	 	redirect_to :action => "comprobar_docente"
    return
 	end

 	@usr=Usuario.buscar_usuario(cedula)
 	@materias=Materia.all

 	if @usr !=nil
	 	if(@usr.es_estudiante? || @usr.es_administrador?)
	 		flash[:error2]="El usuario debe ser Docente"
	 		redirect_to :action => "comprobar_docente"
      return
	 	end
	end

 end

 def guardar_docente_entrega
 	@titulo_pagina= "Asignar Docente"
		
		@materias=Materia.all

		unless(params[:docente_materia] && params[:docente_materia][:materia_id])
	 		 	flash[:error2]="Faltan parametros"
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
		 		bitacora "Se asigno el docente con cedula #{@docente_materia.docente_cedula} a la materia con codigo #{@docente_materia.materia_id},se mando el correo correspondiente"
		 		flash[:exito]="Se asigno el Docente con exito"
		 		AsignarDocente.correo_asignacion(@usr,Materia.existe_materia?(@docente_materia.materia_id))
				redirect_to :action => 'bienvenida',:controller =>'principal'		
				return
		 	else
		 		bitacora "Datos invalidos al asignar un docente a una materia"
		 		render :action => "asignar_docente"
		 	end
		else
			bitacora "Se trato de asignar un docente a una materia que ya tenia asignada"
			flash[:error2] ="El Docente ya tiene asignado la materia"
			render :action =>"asignar_docente"
		end	
	 end
 end

 def guardar_crear_docente_entrega
 	@titulo_pagina= "Asignar Docente" 		
		@materias=Materia.all
		@usr=nil

		unless params[:usuario] && params[:usuario][:nombres] && params[:usuario][:apellidos]  && params[:usuario][:correo]
			flash[:error2]="Faltan parametros"
			bitacora "Faltan parametros"
    	redirect_to :action => 'bienvenida',:controller =>'principal'		
    	return
		end

		if params[:usuario]
			# unless Usuario.buscar_usuario(params[:usuario][:cedula])
		 		@usuario=Usuario.new
		 		@usuario.cedula=params[:usuario][:cedula]
		 		@usuario.nombres=params[:usuario][:nombres]
		 		@usuario.apellidos=params[:usuario][:apellidos]
		 		@usuario.clave =params[:usuario][:cedula]
		 		@usuario.correo=params[:usuario][:correo]

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
			 			bitacora "Se asigno el docente con cedula #{@usuario.cedula} a la materia con codigo #{docente_materia.materia_id} , se mando el correo correspondiente"
						flash[:exito]="Se asigno el Docente con exito"
						AsignarDocente.correo_asignacion(@usuario,Materia.existe_materia?(docente_materia.materia_id))
						redirect_to :action => 'bienvenida',:controller =>'principal'		
						return
		 		else
					bitacora "Datos invalidos al asignar un docente a una materia"
				 	render :action => "asignar_docente"	 			
		 		end

		 	# else
		 	# 	bitacora "El docente ya existe"
		 	# 	flash[:error2]="El Docente ya existe"
		 	# 	render :action => "asignar_docente"
		 	# end
 		end 		
 end

 

 def procesar_eliminar_usuario
 	unless params[:usuario] && params[:usuario][:cedula]
 		flash[:error2]="Faltan parametros"
		bitacora "Faltan parametros"
    redirect_to :action => 'eliminar_usuario'
    return
 	end

 	user_cedula=params[:usuario][:cedula]
 	user=Usuario.buscar_usuario(user_cedula)
 	unless user
 	 	flash[:error2]="El usuario no existe"
		bitacora "No se encontro el usuario con la cedula #{user_cedula}"
    redirect_to :action => 'eliminar_usuario'
    return	
 	end

 	unless session[:usuario].cedula != user_cedula
 		flash[:error2]="No te puedes eliminar tu mismo"
		bitacora "El admin con cedula #{user_cedula} se trato de eliminar"
    redirect_to :action => 'eliminar_usuario'
    return	
 	end

 	#ELIMINAR EL USUARIO
 	user.delete

 	flash[:exito]="El usuario fue eliminado correctamente"
 	bitacora "El admin  con cedula #{session[:usuario].cedula} elimino al usuario con cedula #{user_cedula}"
 	redirect_to  :action =>"bienvenida" ,:controller =>"principal"

 end

 def crear_materia
 	unless params[:materia] && params[:materia][:id] && params[:materia][:nombre]
		flash[:error2]="Faltan Parametros"
		bitacora "Faltan parametros"
		redirect_to :action=>"agregar_materia",:controller=>"administrador"	
		return
	end	 		

	@titulo_pagina= "Agregar Materia"
	@materia=Materia.new
	@materia.id=params[:materia][:id]
	@materia.nombre=params[:materia][:nombre]
	if @materia.save
		bitacora "Se creo la materia #{@materia.nombre}-#{@materia.id} correctamente"	
		flash[:exito]="Se creo la materia correctamente"
		redirect_to :action=>"bienvenida",:controller=>"principal"
		return
	end
		bitacora "Datos invalido al crear materia"
		render :action=>"agregar_materia"		
 end

 def procesar_eliminar_materia
 	unless params[:materia] &&params[:materia][:id]
 		bitacora "Faltan Parametros"
 		flash[:error2]="Faltan Parametros"
 		redirect_to :action=>"eliminar_materia",:controller=>"administrador"
 		return
 	end

 	materia_id=params[:materia][:id]

 	unless !materia_id.empty?
 		flash[:error2]="Debe seleccionar una materia"
 		redirect_to :action=>"eliminar_materia",:controller=>"administrador"
 		return
 	end

 	materia=Materia.existe_materia?(materia_id)
 	descripcion=materia.descripcion
 	materia.delete

 	flash[:exito]="Se elimino correctamente la materia"
 	bitacora "Se elimino la materia #{descripcion} correctamente por el adminostrado #{session[:usuario].descripcion}"
 	redirect_to :action=>"bienvenida",:controller=>"principal"
 	return
 end

 def procesar_registrar_estudiante

 	unless params[:usuario] &&params[:usuario][:cedula] &&params[:usuario][:nombres] &&params[:usuario][:apellidos]&&params[:usuario][:correo]
 		bitacora "Faltan Parametros"
 		flash[:error2]= "Faltan Parametros"
 		redirect_to :action=>"registrar_estudiante",:controller=>"administrador"
 		return
 	end
 	cedula=params[:usuario][:cedula]
 	nombres=params[:usuario][:nombres]
 	apellidos=params[:usuario][:apellidos]
 	correo=params[:usuario][:correo]

 	@usuario=Usuario.new
 	@usuario.cedula=cedula
 	@usuario.nombres=nombres
 	@usuario.apellidos=apellidos
 	@usuario.correo=correo
 	@usuario.clave=Digest::MD5.hexdigest(cedula)
	
	if(@usuario.save)
		est=Estudiante.new
		est.usuario_cedula=@usuario.cedula
		est.save
		CrearEstudiante.correo_crear_estudiante(@usuario)
		bitacora "Estudiante creado con exito,se envio un correo correspondiente"
		flash[:exito]="Se creo el estudiante correctamente"
		redirect_to :action=>"bienvenida",:controller=>"principal"
		return
	else
		bitacora "Intento fallido de registrar estudiante"
		render :action=>"registrar_estudiante"
		return
	end 	

 end

 def procesar_modificar_usuario
 	@titulo_pagina="Modificar Usuario"
 	unless params[:usuario]&&params[:usuario][:cedula]
		bitacora "Faltan Parametros" 		
		flash[:error2]="Faltan Parametros"
		redirect_to :action=>"modificar_usuario"
		return
 	end

 	@cedula=params[:usuario][:cedula]

 	unless @usuario=Usuario.buscar_usuario(@cedula)
 		bitacora "El usuario no existe , accion=Modificar usuario"
 		flash[:error2]="El usuario con cedula #{@cedula} no existe"
 		redirect_to :action=>"modificar_usuario"
 		return
 	end


 end

 def guardar_modificar_usuario
 	@titulo_pagina="Modificar Usuario"
 
 	unless params[:usuario] &&params[:usuario][:cedula] &&params[:usuario][:nombres] &&params[:usuario][:apellidos]&&params[:usuario][:correo]
 		bitacora "Faltan Parametros"
 		flash[:error2]= "Faltan Parametros"
 		redirect_to :action=>"registrar_estudiante",:controller=>"administrador"
 		return
 	end

 	@cedula=params[:usuario_antiguo]
 	cedula_nueva=params[:usuario][:cedula]
 	nombres=params[:usuario][:nombres]
 	apellidos=params[:usuario][:apellidos]
 	correo=params[:usuario][:correo]


 	@usuario=Usuario.buscar_usuario(@cedula)
 	@usuario.cedula=cedula_nueva
 	@usuario.nombres=nombres
 	@usuario.apellidos=apellidos
 	@usuario.correo=correo

 	if @usuario.save
 		bitacora "Usuario #{@usuario.descripcion} se modifico correctamente,se mando el correo correspondiente"
 		flash[:exito]="Usuario modificado correctamente"
 		UsuarioModificar.correo_modificar_usuario(@usuario)
 		redirect_to :action=>"bienvenida",:controller=>"principal"
 		return
 	end
 	render :action=>"procesar_modificar_usuario"
 	return
 end
 
end