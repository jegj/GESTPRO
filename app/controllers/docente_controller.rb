class DocenteController < ApplicationController
		before_filter :verificar_autenticado 
    before_filter :verificar_docente

  def bienvenida
    redirect_to :action=>"bienvenida",:controller=>"principal"
    return
  end

  def verificar_docente
    unless session[:usuario].es_docente?
      bitacora "Intento de accceso sin ser docente"
      flash[:error2]="Debe ser Docente para acceder a estas opciones"
      redirect_to :action => "bienvenida" , :controller => "principal"
      return false
    end
  end

	def crear_entrega
    @titulo_pagina= "Registrar Entrega"
    @materias= session[:rol].materias
  end 

  def ver_estudiantes

    unless params[:materia_id]
      bitacora "Faltan Parametros"
      flash[:error2]="Faltan Parametros"
      redirect_to :action=>"bienvenida",:controller=>"principal"
      return
    end



    materia_id=params[:materia_id]
    unless DocenteMateria.busca_docente_materia(session[:usuario].cedula,materia_id)
      flash[:error2]="Esta materia no le pertenece"  
      bitacora "Intengo de acceso para listar entregables de otra materia"  
      redirect_to :action=>"bienvenida",:controller=>"principal"      
      return
    end

    materia=Materia.existe_materia?(materia_id)
    @titulo_pagina="Estudiantes de #{materia.nombre}"
    @secciones=materia.secciones
    @estudiantes=EstudianteSeccion.obtener_estudiantes(materia_id)
  end

  def consultar_estudiante
    @titulo_pagina="Consultar Estudiante"
  end

  def eliminar_seccion
    @titulo_pagina="Eliminar Seccion"
    @materias= session[:rol].materias
  end

  def agregar_estudiante
    @titulo_pagina="Agregar Estudiante"
    @materias= session[:rol].materias
  end

  def eliminar_estudiante
    @titulo_pagina="Eliminar Estudiante"
    @materias= session[:rol].materias
  end

  def agregar_seccion
    @titulo_pagina="Agregar Seccion" 
    @materias=session[:rol].materias

    # unless params[:materia_id] && params[:materia_nombre]
    #   flash[:mensaje2]="Faltan parametros"
    #    redirect_to  :action=>"bienvenida",:controller=>"principal"
    # end
    # @materia_nombre=params[:materia_nombre]
    # @materia_id=params[:materia_id]
  end

  def ajax_buscar_seccion
    materia_id = params[:materia_id]
    @secciones = Seccion.where(:materia_id => materia_id)
    render :layout =>false
  end

  def ajax_buscar_seccion_agregar
    materia_id=params[:materia_id]
    @secciones = Seccion.where(:materia_id => materia_id)
    render :layout =>false
  end
  
  def procesar_crear_entrega
    
    @titulo_pagina= "Registrar Entrega"
    @materias= session[:rol].materias

    unless params[:entrega] && params[:entrega][:nombre] && params[:entrega][:fecha_entrega] && params[:entrega][:fecha_tope] && params[:entrega][:limite_versiones] && params[:entrega][:archivo_formato] && params[:entrega][:archivo_tamano_max] && params[:entrega][:numero_max_integrantes]
      flash[:error2]="Faltan Parametros"
      bitacora "Faltan parametros"
      redirect_to :action => 'bienvenida',:controller =>'principal'   
      return
    end

    @entrega=Entrega.new
    @entrega.nombre=params[:entrega][:nombre]
    @entrega.fecha_entrega=params[:entrega][:fecha_entrega]
    @entrega.fecha_tope=params[:entrega][:fecha_tope]
    @entrega.limite_versiones=params[:entrega][:limite_versiones]
    @entrega.archivo_formato=params[:entrega][:archivo_formato]
    @entrega.archivo_tamano_max=params[:entrega][:archivo_tamano_max]
    @entrega.numero_max_integrantes=params[:entrega][:numero_max_integrantes]

    # @entrega.save! NSException.exceptionWithName(NSString* name, reason:NSString* reason, userInfo:NSDictionary* userInfo)

    

    unless params[:secciones]
      @entrega.errors[:base]<<"No se ha especificado la seccion."
      render :action =>"crear_entrega"
      return
    end

    unless params[:entrega_archivo] && params[:entrega_archivo][:archivo]
      @entrega.errors[:base]<<"No se ha especificado el archivo."
      render :action =>"crear_entrega"
      return
    end

    subject ="Entrega Nueva"  


    
    if @entrega.save

      if params[:secciones]
        params[:secciones].each {|sec|
          es=EntregaSeccion.new
          es.entrega_id=@entrega.id
          es.seccion_nombre=sec
          es.materia_id=params[:entrega_seccion][:materia_id]
          estudiantes=EstudianteSeccion.where(:seccion_nombre=>es.seccion_nombre ,:materia_id =>es.materia_id)
          materia=Materia.existe_materia?(es.materia_id)
          estudiantes.each {|est|
            user=Usuario.buscar_usuario(est.estudiante_cedula)
            CorreoFechaEntrega.correo_fecha_entrega(user,subject,@entrega,materia)           
          }   
          bitacora "Se envio el correo a los alumnos de la seccion#{es.seccion_nombre} de la materia #{Materia.buscar_materia(es.materia_id)} sobre una entrega nueva"
          es.save      
        }
      end
        archivo=params[:entrega_archivo][:archivo]  
      ea=EntregaArchivo.new
      ea.entrega_id=@entrega.id
      ea.archivo=archivo.read
      ea.tipo=archivo.content_type
      ea.nombre=archivo.original_filename
      ea.save
      
      bitacora "Se creo una nueva entrega con el id  #{@entrega.id} por el docente #{session[:usuario].descripcion}"
      flash[:exito]='Entrega creada con exito'
      redirect_to :action =>'bienvenida',:controller =>"principal"
      return
    end
    render :action => "crear_entrega"
  end  

  def listar_entregables 
    unless params[:entrega_id]
      flash[:error2]="Faltan Parametros"
      redirect_to :action => "bienvenida",:controller=>"principal"
      return
    end
    entrega_id=params[:entrega_id]    

    materia_nombre = EntregaSeccion.buscar_materia(entrega_id)    
    @titulo_pagina="Entregables de #{materia_nombre}"

    materia_id=EntregaSeccion.buscar_materia_id(entrega_id)

    unless DocenteMateria.busca_docente_materia(session[:usuario].cedula,materia_id)
      flash[:error2]="Esta materia no le pertenece"  
      bitacora "Intengo de acceso para listar entregables de otra materia"  
      redirect_to :action=>"bienvenida",:controller=>"principal"      
      return
    end

    @entregable=Entregable.where(:entrega_id => entrega_id)
    @entrega_nombre=Entrega.obtener_nombre(entrega_id)  
  end

  def modificar_entrega
  	@titulo_pagina="Modificar Entrega"
  	unless params[:entrega_id]
  		flash[:error2]="Faltan Parametro"
  		redirect_to :action =>"bienvenida",:controller =>"principal"
      return
  	end

  	entrega_id=params[:entrega_id]
    @materia_id=EntregaSeccion.buscar_materia_id(entrega_id)

    unless DocenteMateria.busca_docente_materia(session[:usuario].cedula,@materia_id)
      flash[:error2]="No puede modificar esta entrega"  
      bitacora "Intengo de acceso para modificar una entrega"  
      redirect_to :action=>"bienvenida",:controller=>"principal"      
      return
    end

  	@entrega=Entrega.buscar_entrega(entrega_id)
  end

  def guardar_modificar_entrega
    @titulo_pagina="Registrar Entrega"
    @materias= session[:rol].materias

    unless params[:entrega] && params[:entrega][:nombre] && params[:entrega][:fecha_entrega] && params[:entrega][:fecha_tope] && params[:entrega][:limite_versiones] && params[:entrega][:archivo_formato] && params[:entrega][:archivo_tamano_max] && params[:entrega][:numero_max_integrantes]
      flash[:error2]="Faltan Parametros"
      bitacora "Faltan parametros"
      redirect_to :action => 'bienvenida',:controller =>'principal'   
      return
    end

    @entrega=Entrega.buscar_entrega(params[:entrega_aux])
  
    @entrega.nombre=params[:entrega][:nombre]
    @entrega.fecha_entrega=params[:entrega][:fecha_entrega]
    @entrega.fecha_tope=params[:entrega][:fecha_tope]
    @entrega.limite_versiones=params[:entrega][:limite_versiones]
    @entrega.archivo_formato=params[:entrega][:archivo_formato]
    @entrega.archivo_tamano_max=params[:entrega][:archivo_tamano_max]
    @entrega.numero_max_integrantes=params[:entrega][:numero_max_integrantes]

    @materia_id=EntregaSeccion.buscar_materia_id(@entrega.id)

    if @entrega.fecha_entrega>@entrega.fecha_tope
      @entrega.errors[:base]<<"La fecha de entrega no puede ser mayor a la fecha tope"
      render :action =>"modificar_entrega"
      return
    end

    unless params[:secciones]
      @entrega.errors[:base]<<"No se ha especificado la seccion."
      render :action =>"modificar_entrega"
      return
    end

    unless params[:entrega_archivo] && params[:entrega_archivo][:archivo]
      @entrega.errors[:base]<<"No se ha especificado el archivo."
      render :action =>"modificar_entrega"
      return
    end
    subject="Entrega Modificada"
    if @entrega.save
      if params[:secciones]
        #borro la secciones y la vuelvo a crear
        EntregaSeccion.eliminar_entrega_seccion(@entrega.id)        
        params[:secciones].each {|sec|
          es=EntregaSeccion.new
          es.entrega_id=@entrega.id
          es.seccion_nombre=sec
          es.materia_id=params[:entrega_seccion]
          estudiantes=EstudianteSeccion.where(:seccion_nombre=>es.seccion_nombre ,:materia_id =>es.materia_id)
          materia=Materia.existe_materia?(es.materia_id)
          estudiantes.each {|est|
            user=Usuario.buscar_usuario(est.estudiante_cedula)
            CorreoFechaEntrega.correo_fecha_entrega(user,subject,@entrega,materia)           
          }   
          bitacora "Se envio el correo a los alumnos de la seccion#{es.seccion_nombre} de la materia #{Materia.buscar_materia(es.materia_id)} sobre la modificacion"

          es.save      
        }
      end
      #borrar archivo
      EntregaArchivo.borrar_archivo(@entrega.id)
      archivo=params[:entrega_archivo][:archivo]  
      ea=EntregaArchivo.new
      ea.entrega_id=@entrega.id
      ea.archivo=archivo.read
      ea.tipo=archivo.content_type
      ea.nombre=archivo.original_filename
      ea.save

      bitacora "se modifico la entrega con id #{@entrega.id}"

      flash[:exito]='Entrega modificada con exito'
      redirect_to :action =>'bienvenida',:controller =>"principal"
      return
    end

    render :action => "modificar_entrega"
  end

  def descargar_entrega
    unless params[:entrega_id]
      flash[:error2]="Faltan parametros"
      bitacora "Faltan parametros"
      redirect_to :action =>"bienvenida",:controller=>"principal"              
      return
    end    
    entrega_id=params[:entrega_id]

    materia_id=EntregaSeccion.buscar_materia_id(entrega_id)

    docente_materia=DocenteMateria.busca_docente_materia(session[:usuario].cedula,materia_id)

    if docente_materia 
      ea=EntregaArchivo.descargar_enunciado(entrega_id)
      if ea 
        bitacora "Se descargo el enunciado de la entrega con id #{params[:entrega_id]}"
        send_data ea.archivo,:content_type =>ea.tipo,:disposition=>"attachment",:filename=>ea.nombre 
      end
    else
      bitacora "Intento de descargar entrega de otra maateria"
      flash[:error2]="No puedes descargar este enunciado"
      redirect_to :action=>"bienvenida",:controller=>"principal"
      return
    end
  end

  def eliminar_entrega
    unless params[:entrega_id]
      flash[:error2]="Faltan parametros"
      bitacora "Faltan parametros"
      redirect_to :action =>"bienvenida",:controller=>"principal"        
      return
    end

    entrega_id=params[:entrega_id]
    entrega=Entrega.buscar_entrega(entrega_id)
    entrega.delete
    bitacora "Se elimino la entrega con id #{params[:entrega_id]}"
    flash[:exito]="La entrega se elimino correctamente"
    redirect_to :action =>"bienvenida",:controller=>"principal"
    return
  end

  def buscar_estudiante
    @titulo_pagina="Resultado Busqueda"

    unless params[:estudiante] &&params[:estudiante][:cedula]
      flash[:error2]="Faltan parametros"
      bitacora "Faltan parametros"
      redirect_to :action => "consultar_estudiante"   
      return
    end

    cedula=params[:estudiante][:cedula]

    if(cedula.empty?)
      flash[:error2]="Introduzca una cedula"
      redirect_to :action => "consultar_estudiante"              
      return
    end

    @user=Usuario.buscar_usuario(cedula) 

    if(@user==nil)
      flash[:error2]="El usuario no existe"
      bitacora "El usuario con cedula #{cedula} no existe"
      redirect_to :action => "consultar_estudiante"        
      return
    end
    
    if((@user.es_docente? || @user.es_administrador? )&& ! @user.es_estudiante?)   
      flash[:error2]="El usuario no es estudiante"
      bitacora "Se trato de buscar informacion de un administrador o docente con cedula #{cedula}"
      redirect_to :action => "consultar_estudiante"      
      return      
    end

    bitacora "Se mostro informacion de #{@user.descripcion}"
    @materias=@user.buscar_estudiante_materia
    
  end

  def procesar_agregar_seccion
    
    unless params[:archivo] && params[:archivo][:excel] && params[:materia] && params[:materia][:id]
      flash[:error2]="Faltan Parametros"     
      bitacora "Faltan parametros"
      redirect_to :action => "agregar_seccion"      
      return      
    end
    
    archivo=params[:archivo][:excel] 
    id=params[:materia][:id]
    ruta=Rails.root.join('excel',archivo.original_filename)

    extension=File.extname(ruta)

    unless extension.eql?(".xls")
      bitacora "La seccion se especifica en un Excel"
      flash[:error2]="El archivo deber ser del tipo Excel(.xls)"
      redirect_to :action=>"agregar_seccion",:controller=>"docente"
      return
    end

    File.open(ruta,'wb') do |file|
      file.write(archivo.read)
    end

    correcto=Procesador.analizar_excel(id,ruta.to_s)
    materia=Materia.existe_materia?(id)
    if correcto["correcto"]
      flash[:exito]="Archivo procesado correctamente"
      seccion=correcto["seccion"]

      correcto["estudiantes"].each do |estudiante|
        unless EstudianteSeccion.where(:estudiante_cedula=>estudiante.to_i,:seccion_nombre=>seccion,:materia_id=>id).first
          est_secc=EstudianteSeccion.new
          est_secc.estudiante_cedula=estudiante.to_i
          est_secc.seccion_nombre=seccion
          est_secc.materia_id=id
          est_secc.save
          usr=Usuario.buscar_usuario(estudiante)
          AsignarSeccionEstudiante.correo_seccion_estudiante(usr,materia,seccion)
        end  
      end

      bitacora "#{correcto['mensaje']} en la materia #{Materia.buscar_materia id} por el docente #{session[:usuario].descripcion}, se mando un correo de aviso a los estudiantes"
      redirect_to :action=>"bienvenida",:controller=>"principal" 
      return
    else
       flash[:error2]="No se pudo procesar el archivo: #{correcto["mensaje"]} , por favor revise el archivo"
       File.delete(ruta)
       bitacora "No se pudo procesar el archivo :#{correcto["mensaje"]} en la materia #{Materia.buscar_materia id}, accion hecha por: docente #{session[:usuario].descripcion}"
       redirect_to :action=>"agregar_seccion"
       return
    end
  end

  def procesar_eliminar_seccion

    unless params[:entrega_seccion] && params[:entrega_seccion][:materia_id]  && params[:secciones]
      bitacora "Se trato de acceder sin parametros"
      flash[:error2] ="Faltan Parametros"
      redirect_to :action=>"eliminar_seccion",:controller=>"docente"
      return
    end

     materia_id=params[:entrega_seccion][:materia_id]
     secciones=params[:secciones]

     secciones.each {|secc|
        Seccion.eliminar_seccion(secc,materia_id)
        bitacora "Se elimino la seccion #{secc} de la materia #{Materia.buscar_materia(materia_id)} por el docente #{session[:usuario].descripcion}"
     }

     flash[:exito]="Se elimino correctamente la seccion(es)"
     redirect_to :action=>"bienvenida",:controller=>"principal"
     return
  end

  def procesar_agregar_estudiante
    unless params[:materia] && params[:materia][:id] &&params[:seccion]&&params[:estudiante]&&params[:estudiante][:cedula]
      bitacora "Faltan Parametros"     
      flash[:error2]="Faltan Parametros"
      redirect_to :action=>"agregar_estudiante",:controller=>"docente"
      return
    end

    seccion_nombre=params[:seccion]
    cedula_estudiante=params[:estudiante][:cedula]
    materia_id=params[:materia][:id]

    unless user=Usuario.buscar_usuario(cedula_estudiante)
      bitacora "El usuario no existe,accion=agregar_estudiante"
      flash[:error2]="El usuario con la cedula #{cedula_estudiante} no esta registrado"
      redirect_to :action =>"agregar_estudiante",:controller=>"docente"
      return
    end

    unless user.es_estudiante?
      bitacora "El usuario no es estudiante,accion=agregar_estudiante"
      flash[:error2]="El usuario con la cedula #{cedula_estudiante} no es estudiante"
      redirect_to :action =>"agregar_estudiante",:controller=>"docente"            
      return
    end

    unless !EstudianteSeccion.buscar_estudiante_seccion(materia_id,seccion_nombre,cedula_estudiante)
      bitacora "El usuario ya se encuentra en esta seccion,accion=agregar_estudiante"
      flash[:error2]="El usuario con la cedula #{cedula_estudiante} ya se encuentra asignado a esta seccion"
      redirect_to :action =>"agregar_estudiante",:controller=>"docente"                
      return
    end  

    unless EstudianteSeccion.where(:estudiante_cedula=>cedula_estudiante,:materia_id=>materia_id).count ==0
      bitacora "El usuario ya se encuentra en otra seccion,accion=agregar_estudiante"
      flash[:error2]="El usuario con la cedula #{cedula_estudiante} ya se encuentra asignado en otra seccion"
      redirect_to :action =>"agregar_estudiante",:controller=>"docente"                
      return               
    end


    est_secc=EstudianteSeccion.new
    est_secc.materia_id=materia_id
    est_secc.seccion_nombre=seccion_nombre
    est_secc.estudiante_cedula=cedula_estudiante
    est_secc.save

    flash[:exito]="Se agrego correctamente el estudiante"
    redirect_to :action=>"bienvenida",:controller=>"principal"
    return
  end

  def procesar_eliminar_estudiante
    unless params[:materia] && params[:materia][:id] &&params[:seccion]&&params[:estudiante]&&params[:estudiante][:cedula]
      bitacora "Faltan Parametros"     
      flash[:error2]="Faltan Parametros"
      redirect_to :action=>"eliminar_estudiante",:controller=>"docente"
      return
    end

    seccion_nombre=params[:seccion]
    cedula_estudiante=params[:estudiante][:cedula]
    materia_id=params[:materia][:id]

    unless user=Usuario.buscar_usuario(cedula_estudiante)
      bitacora "El usuario no existe,accion=agregar_estudiante"
      flash[:error2]="El usuario con la cedula #{cedula_estudiante} no esta registrado"
      redirect_to :action =>"eliminar_estudiante",:controller=>"docente"
      return
    end

    unless user.es_estudiante?
      bitacora "El usuario no es estudiante,accion=agregar_estudiante"
      flash[:error2]="El usuario con la cedula #{cedula_estudiante} no es estudiante"
      redirect_to :action =>"eliminar_estudiante",:controller=>"docente"            
      return
    end

    unless usr=EstudianteSeccion.buscar_estudiante_seccion(materia_id,seccion_nombre,cedula_estudiante)
      bitacora "El usuario no se encuentra en esta seccion,accion=agregar_estudiante"
      flash[:error2]="El usuario con la cedula #{cedula_estudiante} no se encuentra asignado a esta seccion"
      redirect_to :action =>"eliminar_estudiante",:controller=>"docente"                
      return
    end  

    usr.delete
    flash[:exito]="Se elimino correctamente el estudiante de la seccion"
    redirect_to :action=>"bienvenida",:controller=>"principal"
    return    

  end


end