# -*- encoding : utf-8 -*-
class ApplicationController < ActionController::Base
  protect_from_forgery
  
  def bitacora(descripcion)
    b=Bitacora.new
    b.descripcion=descripcion
    b.estudiante_cedula=session[:usuario].cedula if session[:usuario]
    b.fecha_hora=Time.now #Hora del servidor
    b.ip=request.remote_ip #IP accediendo 
    b.save    
  end
    
  def verificar_autenticado
    unless session[:usuario] #else if,tiene quer ser falso
      bitacora "Intento de accceso sin autenticacion"
      flash[:mensaje]="Debe autenticarse"
      redirect_to :action => "index" , :controller => "inicio"
      return false
    end
  end
end
