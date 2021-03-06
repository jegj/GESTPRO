# -*- encoding : utf-8 -*-
class InicioController < ApplicationController
  
  layout "externo" #TODO LOS METODOS USAN ESTE LAYOUT 
  
  def index
    if session[:usuario]
      redirect_to :action => "bienvenida" ,:controller => "principal"
      return
    end
# 	@texto='Hola Mundo'
    #render :layout => "xxx" aaSOLO ESTE METODO USA EL LAYOUT
  end
    
  def validar
    reset_session #Limpia la session
    ci =params[:usuario][:cedula]
    cl =params[:usuario][:clave]
    if usr=Usuario.autenticar(ci,cl)      
      session[:usuario]=usr #guaardo en la session
      bitacora "El usuario #{usr.descripcion} inicio sesion"
      roles=usr.todos_roles   
      if(roles.count<2)
        session[:rol]=usr.rol
        redirect_to :action => "bienvenida" , :controller => "principal"
        return # No puede retornar un redirect
      else
        session[:todos_roles]=roles
        redirect_to :action=>"seleccionar_rol",:controller=>"principal"
        return
      end
    else
      bitacora "Intento fallido de inicio de sesion con cedula:#{ci} y clave:#{cl}"
      flash[:error]="Nombre o Cedula Incorrecta"
      redirect_to :action => "index" 
      return #No puede retornar un redirect
    end
  end
  
  def olvido_contrasena
    @titulo_pagina= "Recuperar Contraseña"
  end
  
  def recordar_contrasena
     unless params[:usuario] && params[:usuario][:cedula] 
        flash[:error2]="Faltan parametros"
        bitacora "Faltan parametros de recuperar clave"
        redirect_to :action => "olvido_contrasena"
        return
     end
     
     cedula=params[:usuario][:cedula]
     usuario=Usuario.where(:cedula => cedula).first
     
     unless usuario
        bitacora "Intento fallido de recuperacion de clave"
        flash[:error2]="Cedula no encontrada"
        redirect_to :action => "olvido_contrasena"
        return
     end
     
     usuario.clave=Digest::MD5.hexdigest(usuario.cedula)
     usuario.save     
     CorreosUsuario.correo_olvide_mi_clave(usuario).deliver
     bitacora "Se envio un correo al usuario #{usuario.nombre_completo} de recuperacion de la contraseña"
     flash[:exito]="Se envio una contraseña nueva al correo"
     redirect_to :action =>"index"
     return
      
  end
   
#   
#   def index2
# 	#@usuario= Usuario.all
# 	@usuario=DocenteMateria.all
# 	#@usuario=Seccion.all
#   end
end

#flash , varible global siempre se borra depeus que se usa
#session , variable global para guardar datos
