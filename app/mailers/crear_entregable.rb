class CrearEntregable < ActionMailer::Base
   default :from => "info@entregas.com"
  
  def correo_crear_entregable(usr,resp,grup,nombr,fech)

  	@usuario=Usuario.buscar_usuario(usr)
  	@responsable=Usuario.buscar_usuario(resp)
  	@grupo=grup
  	@nombre=nombr
  	@fecha=fech
    mail(:to => @usuario.correo,:subject => "Entregable nuevo GESTPRO")
  end
end
