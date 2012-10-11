# -*- encoding : utf-8 -*-
class PrincipalController < ApplicationController
  
  before_filter :verificar_autenticado # antes de ejecutar algo de este controlador cualquier cosa voy correr esto
  
  def bienvenida
    if session[:rol].class.to_s.eql?("Docente")
      @titulo_pagina= "Materias"
    elsif session[:rol].class.to_s.eql?("Administrador")
      @titulo_pagina= "Administrador"     
    elsif session[:rol].class.to_s.eql?("Estudiante")
      @titulo_pagina= "Materias"     
    end
        
  end

  def seleccionar_rol
    @titulo_pagina="Seleccion de Rol"
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

  def olvido_contrasena
    @titulo_pagina= "Recuperar Contraseña"
  end

  
  def cambiar_mi_clave
#     Para evitar accesar por la URL del conrolador
      unless params[:usuario] && params[:usuario][:contrasena_v] &&params[:usuario][:contrasena_n1] && params[:usuario][:contrasena_n2]
          flash[:error2]="Faltan parametros"
          bitacora "Faltan parametros"
          redirect_to :action => "cambiar_clave"
          return
      end
      
      clave_anterior=Digest::MD5.hexdigest(params[:usuario][:contrasena_v])
      clave=params[:usuario][:contrasena_n1]
      clave_conf=params[:usuario][:contrasena_n2]
      usuario=session[:usuario]
      
      if usuario.clave != clave_anterior
        flash[:error2]="Clave anterior no coincide"
        bitacora "Clave anterior no coincide"
        redirect_to :action => "cambiar_clave"
        return
      end
      
      if(clave!=clave_conf)
        flash[:error2]="Claves nuevas no coinciden"
        bitacora "Claves nuevas no coinciden"
        redirect_to :action => "cambiar_clave"
        return
      end
      
      if Digest::MD5.hexdigest(clave)==clave_anterior
        flash[:error2]="Clave anterior coincide con la nueva"
        bitacora "Clave anterior coincide con la nueva"
        redirect_to :action => "cambiar_clave"
        return
      end
      
      if clave.size <= 5
        flash[:error2]="Clave muy corta"
        bitacora "Clave muy corta"
        redirect_to :action => "cambiar_clave"
        return
      end
      

      usuario.clave=Digest::MD5.hexdigest(clave)
      usuario.save
      session[:usuario]=usuario
      
      flash[:exito]="Clave cambiada exitosamente"
      bitacora "Clave cambiada exitoamente"
      redirect_to :action => "bienvenida"
      return
      
  end

  def escoger_rol
    unless params[:rol]
      bitacora "Faltan Parametros"
      flash[:error2]="Faltan Parametros"
      redirect_to :action=>"seleccionar_rol"
    end

    rol=params[:rol]
    if(rol.eql?("Estudiante"))
      session[:rol]=session[:usuario].es_estudiante?
    elsif rol.eql?("Docente")
      session[:rol]=session[:usuario].es_docente?
    elsif rol.eql?("Administrador")
      session[:rol]=session[:usuario].es_administrador?
    end

    bitacora "El usuario #{session[:usuario].descripcion} accedio al rol de #{rol}"
    redirect_to :action=>"bienvenida"
    return
        
  end

end
  

