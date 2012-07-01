# -*- encoding : utf-8 -*-
class PrincipalController < ApplicationController
  
  before_filter :verificar_autenticado # antes de ejecutar algo de este controlador cualquier cosa voy correr esto
  
  def bienvenida
    if session[:usuario].es_docente?
      @titulo_pagina= "Materias"
    elsif session[:usuario].es_administrador?
      @titulo_pagina= "Administrador"     
    elsif session[:usuario].es_estudiante?
      @titulo_pagina= "Materias"     
    end
        
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
  
  def cambiar_mi_clave
#     Para evitar accesar por la URL del conrolador
      unless params[:usuario] && params[:usuario][:contrasena_v] &&params[:usuario][:contrasena_n1] && params[:usuario][:contrasena_n2]
          flash[:mensaje2]="Faltan parametros"
          bitacora "Faltan parametros"
          redirect_to :action => "cambiar_clave"
          return
      end
      
      clave_anterior=params[:usuario][:contrasena_v]
      clave=params[:usuario][:contrasena_n1]
      clave_conf=params[:usuario][:contrasena_n2]
      usuario=session[:usuario]
      
      if usuario.clave != clave_anterior
        flash[:mensaje2]="Clave anterior no coincide"
        bitacora "Clave anterior no coincideaa"
        redirect_to :action => "cambiar_clave"
        return
      end
      
      if(clave!=clave_conf)
        flash[:mensaje2]="Claves nuevas no coinciden"
        bitacora "Claves nuevas no coinciden"
        redirect_to :action => "cambiar_clave"
        return
      end
      
      if clave==clave_anterior
        flash[:mensaje2]="Clave anterior coincide con la nueva"
        bitacora "Clave anterior coincide con la nueva"
        redirect_to :action => "cambiar_clave"
        return
      end
      
      if clave.size <= 5
        flash[:mensaje2]="Clave muy corta"
        bitacora "Clave muy corta"
        redirect_to :action => "cambiar_clave"
        return
      end
      

      usuario.clave=clave
      usuario.save
      session[:usuario]=usuario
      
      flash[:mensaje2]="Clave cambiada exitosamente"
      bitacora "Clave cambiada exitoamente"
      redirect_to :action => "bienvenida"
      return
      
  end
  
  def crear_entrega
    @titulo_pagina= "Registrar Entrega"
    @materias= session[:rol].materias

  end
  
  def registrar_materia
  end  
  
  def olvido_contrasena
    @titulo_pagina= "Recuperar Contraseña"
  end

  def ajax_buscar_seccion
    materia_id = params[:materia_id]
    @secciones = Seccion.where(:materia_id => materia_id)
    render :layout =>false
  end
  def ajax_integrante_otro
    @cantidad = params[:cantidad]
    render :layout =>false
  end
  
  def procesar_crear_entrega
    # @entrega=params[:entrega]
    @titulo_pagina= "Registrar Entrega"
    @materias= session[:rol].materias

    unless params[:entrega] && params[:entrega][:nombre] && params[:entrega][:fecha_entrega] && params[:entrega][:fecha_tope] && params[:entrega][:limite_versiones] && params[:entrega][:archivo_formato] && params[:entrega][:archivo_tamano_max] && params[:entrega][:numero_max_integrantes]
      flash[:mensaje2]="Faltan Parametros"
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
      
    
    if @entrega.save
      if params[:secciones]
        params[:secciones].each {|sec|
          es=EntregaSeccion.new
          es.entrega_id=@entrega.id
          es.seccion_nombre=sec
          es.materia_id=params[:entrega_seccion][:materia_id]
          es.save      
        }
      end
      flash[:mensaje2]='Entrega creada con exito'
      redirect_to :action =>'bienvenida'
      return
    end

    render :action => "crear_entrega"
  end  

  def listar_entregables 
    unless params[:entrega_id]
      flash[:mensaje2]="Faltan Parametros"
      render :action => "bienvenida"
      return
    end
    materia_nombre = EntregaSeccion.buscar_materia(params[:entrega_id])    
    @titulo_pagina="Entregables de #{materia_nombre}"
    @entregable=Entregable.where(:entrega_id => params[:entrega_id])
    @entrega_nombre=Entrega.obtener_nombre(params[:entrega_id])  
  end
  
  #********************************************************
  def listar_mis_entregables
    unless params[:entrega_id] || session[:usuario].cedula
      flash[:mensaje2]="Faltan Parametros"
      render :action => "bienvenida"
      return
    end
    
    materia_nombre = EntregaSeccion.buscar_materia(params[:entrega_id])    
    @titulo_pagina="Entregable de #{materia_nombre}"

    grupo=EstudianteGrupo.where(:entrega_id => params[:entrega_id],:estudiante_cedula => session[:usuario].cedula)

    if(grupo != [])

      grupo=grupo.first
      grupo=grupo.grupo_nro
      @entregable=Entregable.where(:entrega_id => params[:entrega_id], :grupo_nro => grupo)
    else
      @entregable=-1
      return
    end

  end

  def realizar_entrega

    unless params[:entrega_id] and session[:usuario].cedula
      flash[:mensaje2]="Faltan Parametros"
      render :action => "bienvenida"
      return
    end

    @titulo_pagina= "Realizar Entrega"
    numero =Entrega.where(:id => params[:entrega_id]).first.numero_max_integrantes
    @integrantes=[[1,1]]
    for x in (2..Integer(numero))
      @integrantes+= [[x,x]]
    end

    @cedula = session[:usuario].cedula
    @entrega_id = params[:entrega_id]

  end
 #******************************************************** 
 # REVISAR /IMPORTANTE
  def procesar_realizar_entrega
    sa
    tieneGrupo=EstudianteGrupo.where(:estudiante_cedula=> session[:usuario].cedula,:entrega_id => params[:entrega_id])

     
    if tieneGrupo!=[]
      
      tiene=true

      tieneGrupo=tieneGrupo.first.grupo_nro;
      # Tiene grupo pero revisemos los otros
      cantidad=Integer(params[:entregable][:numero_integrantes])

      for x in [2..cantidad]
        unless EstudianteGrupo.where(:estudiante_cedula=>params[:entregable][:integrantes],:entrega_id => params[:entrega_id],:grupo_nro => tieneGrupo)
          tiene=false
           
        end
        
      end
      #Algun otro no pertecia a ese grupo
      unless tiene

        entregable_integrantes=Integer(session[:usuario].cedula)
        entrega_id=Integer(params[:entrega_id])
        numero_integrantes=Integer(params[:entregable][:numero_integrantes])
      
        archivo=params[:archivo]
        

        @grupoS = EstudianteGrupo.new
        @grupoS.estudiante_cedula=entregable_integrantes
        @grupoS.entrega_id=entrega_id

        nGrupo=EstudianteGrupo.maximum(:grupo_nro)+1
        @grupoS.grupo_nro=nGrupo
        @nuevoGrupo = Grupo.new
        @nuevoGrupo.entrega_id=entrega_id
        @nuevoGrupo.nro=nGrupo
        @nuevoGrupo.save
        @grupoS.save
        bitacora "Se almaceno el nuevo grupo #{nGrupo} de la entrega #{entrega_id}"
        cantidad=Integer(numero_integrantes)

      
        if numero_integrantes>=2
          if Estudiante.where(:usuario_cedula=> params[:entregable]["2"])
            integrantes=Integer(params[:entregable]["2"])
            @NgrupoS = EstudianteGrupo.new

            @NgrupoS.estudiante_cedula=integrantes
            @NgrupoS.grupo_nro=nGrupo
            @NgrupoS.entrega_id=entrega_id
            bitacora "Se almaceno el integrante #{integrantes} perteneciente al grupo #{nGrupo} de la entrega #{entrega_id}"
            @NgrupoS.save
          else
            @entregable.errors[:base]<<"La cedula del integrante 2 no corresponde a la de un Estudiante."
            render :action =>"realizar_entrega"
            return

          end

        end
        if numero_integrantes>=3
          if Estudiante.where(:usuario_cedula=> params[:entregable]["3"])
            integrantes=Integer(params[:entregable]["3"])
            @NgrupoS = EstudianteGrupo.new
            @NgrupoS.estudiante_cedula=integrantes
            @NgrupoS.grupo_nro=nGrupo
            @NgrupoS.entrega_id=entrega_id
            bitacora "Se almaceno el integrante #{integrantes} perteneciente al grupo #{nGrupo} de la entrega #{entrega_id}"
            @NgrupoS.save
          else
            @entregable.errors[:base]<<"La cedula del integrante 3 no corresponde a la de un Estudiante."
            render :action =>"realizar_entrega"
            return
          end
        end
        
        @entregableN=Entregable.new
        @entregableN.grupo_nro=nGrupo
        @entregableN.entrega_id=entrega_id
        @entregableN.estudiante_cedula_entrego=entregable_integrantes
        @entregableN.fecha_hora=Time.now
        @entregableN.version=1
        @entregableN.save
        bitacora "El estudiante #{entregable_integrantes} almaceno un Entregable a las #{@entregableN.fecha_hora} perteneciente al grupo #{nGrupo} de la entrega #{entrega_id}"
        @entregableAN=EntregableArchivo.new
        @entregableAN.grupo_nro=nGrupo
        @entregableAN.entrega_id=entrega_id
        archivo=archivo
        @entregableAN.archivo=archivo
        if archivo
          @entregableAN.nombre=archivo[0,archivo.length-3]
          @entregableAN.tipo=archivo[archivo.length-3,archivo.length]
        
          @entregableAN.save
          bitacora "Se guardo el archivo #{archivo} perteneciente a la entrega #{entrega_id} del grupo #{nGrupo}"
        end  
      
      end
        #Tienen grupo y s l mismo

      if tiene
        entregable_integrantes=Integer(session[:usuario].cedula)
        entrega_id=Integer(params[:entrega_id])
        numero_integrantes=Integer(params[:entregable][:numero_integrantes])
      
        archivo=params[:archivo]
      
        nGrupo=EstudianteGrupo.where(:estudiante_cedula=> entregable_integrantes,:entrega_id => entrega_id).first.grupo_nro
       
        @entregableN=Entregable.new
        @entregableN.grupo_nro=nGrupo
        @entregableN.entrega_id=entrega_id
        @entregableN.estudiante_cedula_entrego=entregable_integrantes
        @entregableN.fecha_hora=Time.now
        @entregableN.version=1
        @entregableN.save
        bitacora "El estudiante #{entregable_integrantes} almaceno un Entregable a las #{@entregableN.fecha_hora} perteneciente al grupo #{nGrupo} de la entrega #{entrega_id}"
        @entregableAN=EntregableArchivo.new
        @entregableAN.grupo_nro=nGrupo
        @entregableAN.entrega_id=entrega_id
        archivo=archivo
        @entregableAN.archivo=archivo
        if archivo
          @entregableAN.nombre=archivo[0,archivo.length-3]
          @entregableAN.tipo=archivo[archivo.length-3,archivo.length]
        
          @entregableAN.save
          bitacora "Se guardo el archivo #{archivo} perteneciente a la entrega #{entrega_id} del grupo #{nGrupo}"
        end
      end

    end
    #No tiene grupo
    
    if tieneGrupo==[]
      
      bitacora "No tiene grupo"
      entregable_integrantes=Integer(session[:usuario].cedula)
      entrega_id=Integer(params[:entrega_id])
      numero_integrantes=Integer(params[:entregable][:numero_integrantes])
      
      archivo=params[:archivo]
      

      @grupoS = EstudianteGrupo.new
      @grupoS.estudiante_cedula=entregable_integrantes
      @grupoS.entrega_id=entrega_id
      bitacora "Estudiante Grupo"

      nGrupo=(EstudianteGrupo.maximum(:grupo_nro))
      if nGrupo == nil
        nGrupo=0
      else
        nGrupo=nGrupo+1
      end
      @grupoS.grupo_nro=nGrupo
      @nuevoGrupo = Grupo.new
      @nuevoGrupo.entrega_id=entrega_id
      @nuevoGrupo.nro=nGrupo
      @nuevoGrupo.save
      @grupoS.save
      bitacora "Se almaceno el nuevo grupo #{nGrupo} de la entrega #{entrega_id}"
      cantidad=Integer(numero_integrantes)

      
      if numero_integrantes>=2
        if Estudiante.where(:usuario_cedula => params[:entregable]["2"])
          integrantes=Integer(params[:entregable]["2"])
          @NgrupoS = EstudianteGrupo.new
          @NgrupoS.estudiante_cedula=integrantes
          @NgrupoS.grupo_nro=nGrupo
          @NgrupoS.entrega_id=entrega_id
          bitacora "Se almaceno el integrante #{integrantes} perteneciente al grupo #{nGrupo} de la entrega #{entrega_id}"
          @NgrupoS.save
        end
        unless Estudiante.where(:usuario_cedula => params[:entregable]["2"])
          @entregable.errors[:base]<<"La cedula del integrante 2 no corresponde a la de un Estudiante."
          render :action =>"realizar_entrega"
          return

        end

      end
      if numero_integrantes>=3
        if Estudiante.where(:usuario_cedula => params[:entregable]["3"])
          integrantes=Integer(params[:entregable]["3"])
          @NgrupoS = EstudianteGrupo.new
          @NgrupoS.estudiante_cedula=integrantes
          @NgrupoS.grupo_nro=nGrupo
          @NgrupoS.entrega_id=entrega_id
          bitacora "Se almaceno el integrante #{integrantes} perteneciente al grupo #{nGrupo} de la entrega #{entrega_id}"
          @NgrupoS.save
        else
          @entregable.errors[:base]<<"La cedula del integrante 3 no corresponde a la de un Estudiante."
          render :action =>"realizar_entrega"
          return
        end
      end
      
      @entregableN=Entregable.new
      @entregableN.grupo_nro=nGrupo
      @entregableN.entrega_id=entrega_id
      @entregableN.estudiante_cedula_entrego=entregable_integrantes
      @entregableN.fecha_hora=Time.now
      @entregableN.version=1
      @entregableN.save
      bitacora "El estudiante #{entregable_integrantes} almaceno un Entregable a las #{@entregableN.fecha_hora} perteneciente al grupo #{nGrupo} de la entrega #{entrega_id}"
      @entregableAN=EntregableArchivo.new
      @entregableAN.grupo_nro=nGrupo
      @entregableAN.entrega_id=entrega_id
      archivo=archivo
      @entregableAN.archivo=archivo
      if archivo
        @entregableAN.nombre=archivo[0,archivo.length-3]
        @entregableAN.tipo=archivo[archivo.length-3,archivo.length]
      
        @entregableAN.save
        bitacora "Se guardo el archivo #{archivo} perteneciente a la entrega #{entrega_id} del grupo #{nGrupo}"
      end 
    end
    flash[:mensaje2]='Entrega realizada con exito'
    redirect_to :action =>'bienvenida'
  end
end
  

