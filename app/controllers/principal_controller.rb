# -*- encoding : utf-8 -*-
class PrincipalController < ApplicationController
  
  before_filter :verificar_autenticado # antes de ejecutar algo de este controlador cualquier cosa voy correr esto
  
  def bienvenida
    if session[:usuario].es_docente?
      @titulo_pagina= "Materias"
    elsif session[:usuario].es_administrador?
      @titulo_pagina= "Administrador"     
    elsif session[:usuario].es_estudiante?
      @titulo_pagina= "Estudiante"     
    end
        
  end

  def cerrar_sesion
    bitacora "EL usuario #{session[:usuario].descripcion} ha cerrado sesion"
    reset_session
    redirect_to :action => "index" , :controller => "inicio"
    return
  end
  
  def cambiar_clave
    @titulo_pagina= "Cambio mi clave"  
  end
  
  def cambiar_mi_clave
#     Para evitar accesar por la URL del conrolador
      unless params[:usuario] && params[:usuario][:contrasena_v] &&params[:usuario][:contrasena_n1] && params[:usuario][:contrasena_n2]
          flash[:mensaje2]="Faltan parametros"
          bitacora "Faltan parametros"
          redirect_to :action => "cambiar_clave"
          return
      end
      
      clave_anterior=params[:usuario][:contrasena_v]
      clave=params[:usuario][:contrasena_n1]
      clave_conf=params[:usuario][:contrasena_n2]
      usuario=session[:usuario]
      
      if usuario.clave != clave_anterior
        flash[:mensaje2]="Clave anterior no coincide"
        bitacora "Clave anterior no coincideaa"
        redirect_to :action => "cambiar_clave"
        return
      end
      
      if(clave!=clave_conf)
        flash[:mensaje2]="Claves nuevas no coinciden"
        bitacora "Claves nuevas no coinciden"
        redirect_to :action => "cambiar_clave"
        return
      end
      
      if clave==clave_anterior
        flash[:mensaje2]="Clave anterior coincide con la nueva"
        bitacora "Clave anterior coincide con la nueva"
        redirect_to :action => "cambiar_clave"
        return
      end
      
      if clave.size <= 5
        flash[:mensaje2]="Clave muy corta"
        bitacora "Clave muy corta"
        redirect_to :action => "cambiar_clave"
        return
      end
      

      usuario.clave=clave
      usuario.save
      session[:usuario]=usuario
      
      flash[:mensaje2]="Clave cambiada exitosamente"
      bitacora "Clave cambiada exitoamente"
      redirect_to :action => "bienvenida"
      return
      
  end
  
  def crear_entrega
    @titulo_pagina= "Registrar Entrega"
    @materias= session[:rol].materias

  end
  
  def registrar_materia
  end  
  
  def olvido_contrasena
    @titulo_pagina= "Recuperar Contraseña"
  end

  def ajax_buscar_seccion
    materia_id = params[:materia_id]
    @secciones = Seccion.where(:materia_id => materia_id)
    render :layout =>false
  end
  
  def procesar_crear_entrega
    # @entrega=params[:entrega]

    @entrega=Entrega.new
    @entrega.nombre=params[:entrega][:nombre]
    @entrega.fecha_entrega=params[:entrega][:fecha_entrega]
    @entrega.fecha_tope=params[:entrega][:fecha_tope]
    @entrega.limite_versiones=params[:entrega][:limite_versiones]
    @entrega.archivo_formato=params[:entrega][:archivo_formato]
    @entrega.archivo_tamano_max=params[:entrega][:archivo_tamano_max]
    @entrega.numero_max_integrantes=params[:entrega][:numero_max_integrantes]

    # @entrega.save! NSException.exceptionWithName(NSString* name, reason:NSString* reason, userInfo:NSDictionary* userInfo)

    @titulo_pagina= "Registrar Entrega"
    @materias= session[:rol].materias

    unless params[:secciones]
      @entrega.errors[:base]<<"No se ha especificado la seccion."
      render :action =>"crear_entrega"
      return
    end
      
    
    if @entrega.save
      if params[:secciones]
        params[:secciones].each {|sec|
          es=EntregaSeccion.new
          es.entrega_id=@entrega.id
          es.seccion_nombre=sec
          es.materia_id=params[:entrega_seccion][:materia_id]
          es.save      
        }
      end


      flash[:mensaje2]='Entrega creada con exito'
      redirect_to :action =>'bienvenida'
      return
    end

    render :action => "crear_entrega"
  end  

  def listar_entregables 
    unless params[:entrega_id]
      flash[:mensaje2]="Faltan Parametros"
      render :action => "bienvenida"
      
      return
    end
    materia_nombre = EntregaSeccion.buscar_materia(params[:entrega_id])    
    @titulo_pagina="Entregables de #{materia_nombre}"
    @entregable=Entregable.where(:entrega_id => params[:entrega_id])
  end
  
end
