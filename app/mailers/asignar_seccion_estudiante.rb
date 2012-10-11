class AsignarSeccionEstudiante < ActionMailer::Base
  default :from => "info@entregas.com"

  def correo_seccion_estudiante(usr,materia,seccion)
  	@materia=materia
  	@usuario=usr
  	@seccion=seccion
  	mail(:to =>usr.correo,:subject=>"Asignacion de Seccion")
  end
end
