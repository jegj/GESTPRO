class AsignarDocente < ActionMailer::Base
  default :from => "info@entregas.com"

  def correo_asignacion(usr,mat)
  	@usuario=usr
  	@materia=mat
  	mail(:to=>usr.correo,:subject=>"Asignacion de Materia")
  end

end
