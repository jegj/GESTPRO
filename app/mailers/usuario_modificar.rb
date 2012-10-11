class UsuarioModificar < ActionMailer::Base
  default :from => "info@entregas.com"
  
  def correo_modificar_usuario(usr)
  	@usuario=usr
    mail(:to => usr.correo,:subject => "Modificaciones en la cuenta")
  end
end
