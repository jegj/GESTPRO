class CrearEstudiante < ActionMailer::Base
  default :from => "info@entregas.com"
  
  def correo_crear_estudiante(usr)
  	@usuario=usr
    mail(:to => usr.correo,:subject => "Cuenta GESTPRO")
  end
end
