class CorreoFechaEntrega < ActionMailer::Base
  default :from => "info@entregas.com"

  def correo_fecha_entrega(usr,subject,entrega,materia)
  		@usuario=usr
  		@entrega=entrega
  		@materia=materia
	  	mail(:to=>usr.correo,:subject=>subject)
  end
end
	