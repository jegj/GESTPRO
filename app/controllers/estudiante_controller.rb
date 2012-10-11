class EstudianteController < ApplicationController
	before_filter :verificar_autenticado
  before_filter :verificar_estudiante

  def verificar_estudiante
    unless session[:usuario].es_estudiante?
      bitacora "Intento de accceso sin ser estudiante"
      flash[:error2]="Debe ser Estudiante para acceder a estas opciones"
      redirect_to :action => "bienvenida" , :controller => "principal"
      return false
    end
  end

  def bienvenida
    redirect_to :action=>"bienvenida",:controller=>"principal"
    return
  end

  def ajax_integrante_otro
    @cantidad = params[:cantidad].to_i
    render :layout =>false
  end

  def descargar_enunciado
    unless params[:entrega_id]
      bitacora "Faltan Parametros"
      flash[:error2]="Faltan Parametros"
      redirect_to :action=>"bienvenida",:controller=>"principal"
      return
    end

    entrega_id=params[:entrega_id]
    materia_id=EntregaSeccion.buscar_materia_id(entrega_id)
    entrega_secciones=EntregaSeccion.buscar_secciones(entrega_id).collect{|entrega_seccion| entrega_seccion.seccion_nombre}
    valido=false
    entrega_secciones.each do |seccion|
      if EstudianteSeccion.buscar_estudiante_seccion(materia_id,seccion,session[:usuario].cedula)
        valido=true
      end
    end

    if valido 
      entrega_archivo=EntregaArchivo.descargar_enunciado(entrega_id)
      if entrega_archivo
        bitacora "Se descargo el enunciado de la entrega #{Entrega.obtener_nombre(entrega_id)}"
        send_data entrega_archivo.archivo,:content_type =>entrega_archivo.tipo,:disposition=>"attachment",:filename=>entrega_archivo.nombre
      end 
    else
      bitacora "Intento de acceso para descargar otro enunciado"
      flash[:error2]="No puedes descargar este enunciado"      
      redirect_to :action=>"bienvenida",:controller=>"principal"
      return
    end

  end

  def descargar_entregable
    unless params[:entrega_id]
      bitacora "Faltan Parametros"
      flash[:error2]="Faltan Parametros"
      redirect_to :action=>"bienvenida",:controller=>"principal"
      return
    end
    unless params[:version]
      bitacora "Faltan Parametros"
      flash[:error2]="Faltan Parametros"
      redirect_to :action=>"bienvenida",:controller=>"principal"
      return
    end

    entrega_id=params[:entrega_id]
    version=params[:version]
    grupo=EstudianteGrupo.where(:entrega_id => entrega_id,:estudiante_cedula => session[:usuario].cedula)

    if(grupo != [])

      grupo=grupo.last
      grupo=grupo.grupo_nro
      entregable=EntregableArchivo.where(:entrega_id => entrega_id, :grupo_nro => grupo, :version => version).order("version").reverse_order.first
      valido=true
    else
      entregable=-1
      valido=false
      return
    end
    if valido
      
      if entregable
        bitacora "Se descargo el entregable #{entregable.nombre} del grupo #{grupo} de la entrega #{Entrega.obtener_nombre(entrega_id)}"
        send_data entregable.archivo,:content_type =>entregable.tipo,:disposition=>"attachment",:filename=> entregable.nombre
      end 
    else
      bitacora "Intento de acceso para descargar otro enunciado"
      flash[:error2]="No puedes descargar este enunciado"      
      redirect_to :action=>"bienvenida",:controller=>"principal"
      return
    end

  end


  def realizar_entrega
    unless params[:entrega_id]
      bitacora "Faltan Parametros"
      flash[:error2]="Faltan Parametros"
      redirect_to :action=>"bienvenida",:controller=>"principal"
      return
    end

    #validar que vea la materia y este en la seccion
    entrega_id=params[:entrega_id]
    entrega_fecha_tope=Entrega.buscar_entrega(entrega_id).fecha_tope

    unless Date.today < entrega_fecha_tope
      bitacora "Intento de envio de una materia que paso la fecha de entrega"
      flash[:error2]="Ya paso la fecha de entrega"
      redirect_to :action=>"bienvenida",:controller=>"principal"
      return
    end

    materia=EntregaSeccion.obtener_materia(entrega_id)
    @materia_nombre=materia.nombre
    @entrega_nombre=Entrega.obtener_nombre(params[:entrega_id])
    @titulo_pagina= "Realizar Entrega"

    materia_id=materia.id
    unless seccion_estudiante= EstudianteSeccion.buscar_seccion(materia_id,session[:usuario].cedula)   
      bitacora "Intento de acceso de enviar entregable de otra materia"
      flash[:error2]="Esta materia no le pertence"      
      redirect_to :action=>"bienvenida",:controller=>"principal"
      return
    end  

    seccion_estudiante=seccion_estudiante.seccion_nombre  
    unless EntregaSeccion.existe_entrega_seccion(entrega_id,seccion_estudiante,materia_id)
      bitacora "Intento de acceso de enviar entrega de otra seccion"         
      flash[:error2]="No pertenece a la seccion"      
      redirect_to :action=>"bienvenida",:controller=>"principal"
      return
    end



    numero =Entrega.where(:id => params[:entrega_id]).first
    if(!numero.blank?)
      numero=numero.numero_max_integrantes
    else
      bitacora "Intento de acceso una entrega no existente"
      flash[:error2]="Esta entrega no esta disponible"      
      redirect_to :action=>"bienvenida",:controller=>"principal"
      return false;
    end

    @integrantes=[[1,1]]

    for x in (2..Integer(numero))
      @integrantes+= [[x,x]]
    end
    @entrega_id = params[:entrega_id]
    @cedula=session[:usuario].cedula
  end


  

  def listar_mis_entregables

    unless params[:entrega_id] && session[:usuario].cedula
      flash[:error2]="Faltan Parametros"
      render :action => "bienvenida",:controller=>"principal"
      return
    end

    entrega_id=params[:entrega_id]
    materia=EntregaSeccion.obtener_materia(entrega_id)  
    materia_nombre =materia.nombre
    materia_id=materia.id
    @titulo_pagina="Entregable de #{materia_nombre}"

    unless seccion_estudiante= EstudianteSeccion.buscar_seccion(materia_id,session[:usuario].cedula)   
      bitacora "Intento de acceso de listar entregables de otra materia"
      flash[:error2]="Esta materia no le pertence"      
      redirect_to :action=>"bienvenida",:controller=>"principal"
      return
    end  

    seccion_estudiante=seccion_estudiante.seccion_nombre  
    unless EntregaSeccion.existe_entrega_seccion(entrega_id,seccion_estudiante,materia_id)
      bitacora "Intento de acceso de enviar entrega de otra seccion"         
      flash[:error2]="No pertenece a la seccion"      
      redirect_to :action=>"bienvenida",:controller=>"principal"
      return
    end


    grupo=EstudianteGrupo.where(:entrega_id => params[:entrega_id],:estudiante_cedula => session[:usuario].cedula)

    if(grupo != [])

      grupo=grupo.last
      grupo=grupo.grupo_nro
      @entregable=Entregable.where(:entrega_id => params[:entrega_id], :grupo_nro => grupo).order("version").reverse_order
      cantidad=EstudianteGrupo.where("grupo_nro = ? and entrega_id = ? and estudiante_cedula != ? ",grupo,params[:entrega_id],session[:usuario].cedula)
      @cuantos=cantidad.count
      @integrantes=cantidad.select("estudiante_cedula")
    else
      @entregable=-1
      return
    end
  end


  def procesar_realizar_entrega

    unless params[:entregable_integrantes] &&params[:entrega_id] && params[:entregable] &&params[:entregable][:numero_integrantes]
      bitacora "Faltan Parametros"      
      flash[:error2]="Faltan Parametros"
      redirect_to :action=>"bienvenida",:controller=>"principal"
      return
    end

    @titulo_pagina="Realizar Entrega"
    entrega_id=Integer(params[:entrega_id])
    trega=Entrega.where(:id => entrega_id).first

    #Datos esenciales de validaciones del archivo
    formatoO=trega.archivo_formato
    
    
    limiteO=trega.limite_versiones
    tamO=trega.archivo_tamano_max
    fecha_tope=trega.fecha_tope
    fecha_entrega=trega.fecha_entrega

   
   
    
    tieneGrupo=EstudianteGrupo.where(:estudiante_cedula=> session[:usuario].cedula,:entrega_id => params[:entrega_id])    
    
    if tieneGrupo!=[]
      # Tiene grupo pero revisemos los otros
      tiene=true
      #Numero del grupo
      tieneGrupo=tieneGrupo.first.grupo_nro;
      unless(params[:entregable][:numero_integrantes].blank?)

        cantidad=Integer(params[:entregable][:numero_integrantes])
      else
        cantidad=1
      end
      unless(params[:integrantes].blank?)
        for x in [0..cantidad-1]

          unless EstudianteGrupo.where(:estudiante_cedula=>params[:integrantes][x],:entrega_id => params[:entrega_id],:grupo_nro => tieneGrupo)
          #Alguno del grupo no tenia grupo
            tiene=false
             
          end
          
        end
      else
          tiene=true;
      end


      
      #Algun otro no pertecia a ese grupo
      unless tiene
        bitacora "tenia grupo pero este es nuevo"
        entregable_integrantes=Integer(session[:usuario].cedula)
        unless(params[:entregable][:numero_integrantes].blank?)

          numero_integrantes=Integer(params[:entregable][:numero_integrantes])
        else
          numero_integrantes=1
        end
        
      #Verificar que vean la materia y tengan esa entrega

      #Materia y seccion de la entrega

        materia_entrega=EntregaSeccion.where(:entrega_id => entrega_id.to_i)
        no_cursa=true;
        errores="";
        #MAteria y seccion del integrante y de la entrega
        i=0
        nop=false
        ced=90909090;

        if(!params[:integrantes].blank?)
          params[:integrantes].each do |integrante|
            ced=integrante;
            materia_entrega.each do |materia_sec|

              mate=materia_sec.materia_id
              sec=materia_sec.seccion_nombre
             
              unless Estudiante.cursa(integrante,mate,sec).blank?
              #Alguno del grupo no tenia asignada la entrega
                
                no_cursa=false;
                
              end

            end
            if (no_cursa)
              no_cursa=true
              nop=true
              bitacora "El estudiante #{ced} no tiene asignada la entrega #{entrega_id}"
              errores33="El estudiante #{integrante} no tiene asignada la entrega #{entrega_id}\n"
              errores="#{errores}\n #{errores33}"
            end

            
          end
          if(no_cursa)
            flash[:error2]=errores;
            redirect_to :action => "bienvenida" , :controller => "principal"
            return false
          end
        end
        #Comienzo y verifico archivo
        archivo=params[:entregable][:archivo]
        unless archivo.blank?

          @entregableAN=EntregableArchivo.new
          
          @entregableAN.entrega_id=entrega_id
          @entregableAN.archivo=archivo.read
          @entregableAN.tipo=archivo.content_type
          @entregableAN.nombre=archivo.original_filename

        
          tip=false;
          tipe="";
          nn = archivo.content_type
          for t in (0..nn.size)
            
            if(tip)
              tipe="#{tipe}#{nn[t]}";
            end
            if(nn[t]=="/")
              tip=true;
            end
          end

          errores="";
          abortar=false;

          if(tipe!=formatoO)
            bitacora "Archivo no compatible, debe ser de tipo #{formatoO}"
            errores="#{errores}Archivo no compatible, debe ser de tipo #{formatoO}\n"
            abortar=true;
          end
          tamA=(0.000976562*(archivo.size));
          if (tamA>tamO)
            abortar=true;
            bitacora "Archivo #{tamA} KB sobrepasa el tamano establecido #{tamO} KB"
            errores="#{errores}Archivo #{tamA} KB sobrepasa el tamano establecido #{tamO} KB\n"
          end

          if(Time.now>fecha_tope)
            abortar=true;
            bitacora "Ya paso la fecha limite #{fecha_tope}"
            errores="#{errores}Ya paso la fecha limite #{fecha_tope}\n"
          end
          if (abortar)
            flash[:error2]=errores;
            redirect_to :action => "bienvenida" , :controller => "principal"
            return false
          end

           
        else
          flash[:error2]="No puede existir una entrega vacia";
          redirect_to :action => "bienvenida" , :controller => "principal"
          return false
        end
        @grupoS = EstudianteGrupo.new
        @grupoS.estudiante_cedula=entregable_integrantes
        @grupoS.entrega_id=entrega_id

        nGrupo=EstudianteGrupo.maximum(:grupo_nro)
        if(nGrupo.blank?)
          nGrupo=0;
        end
        nGrupo=nGrupo+1
        @grupoS.grupo_nro=nGrupo
        @nuevoGrupo = Grupo.new
        @nuevoGrupo.entrega_id=entrega_id
        @nuevoGrupo.nro=nGrupo
        @nuevoGrupo.save
        @grupoS.save
        bitacora "Se almaceno el nuevo grupo #{nGrupo} de la entrega #{entrega_id}"
        bitacora "Se almaceno el integrante #{entregable_integrantes} perteneciente al grupo #{nGrupo} de la entrega #{entrega_id}"
        cantidad=Integer(numero_integrantes)
        unless(params[:integrantes].blank?)
          for x in (0..cantidad-1)

              integrantes=Integer(params[:integrantes][x])
              @NgrupoS = EstudianteGrupo.new
              @NgrupoS.estudiante_cedula=integrantes
              @NgrupoS.grupo_nro=nGrupo
              @NgrupoS.entrega_id=entrega_id
              bitacora "Se almaceno el integrante #{integrantes} perteneciente al grupo #{nGrupo} de la entrega #{entrega_id}"
              @NgrupoS.save
            
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
        @entregableAN.grupo_nro=nGrupo
        @entregableAN.version=@entregableN.version
        @entregableAN.save
        bitacora "Se guardo el archivo #{archivo} perteneciente a la entrega #{entrega_id} del grupo #{nGrupo}"
        #Correoo
        CrearEntregable.correo_crear_entregable(entregable_integrantes,@entregableN.estudiante_cedula_entrego,nGrupo,@entregableAN.nombre,@entregableN.fecha_hora)
        unless(params[:integrantes].blank?)
          for x in (0..cantidad-1)

              integrantes=Integer(params[:integrantes][x])
              CrearEntregable.correo_crear_entregable(integrantes,@entregableN.estudiante_cedula_entrego,nGrupo,@entregableAN.nombre,@entregableN.fecha_hora)
            
          end
        end
        

      end
        #Tienen grupo y s l mismo

      if tiene
        
        #Comienzo y verifico archivo
        archivo=params[:entregable][:archivo]
        unless archivo.blank?

          @entregableAN=EntregableArchivo.new
          
          @entregableAN.entrega_id=entrega_id

          @entregableAN.archivo=archivo.read
          @entregableAN.tipo=archivo.content_type
          @entregableAN.nombre=archivo.original_filename
          nGrupo=EstudianteGrupo.where(:estudiante_cedula=> session[:usuario].cedula,:entrega_id => params[:entrega_id]).last.grupo_nro;
          
          @entregableAN.grupo_nro=nGrupo;

       
          tip=false;
          tipe="";
          nn = archivo.content_type
          for t in (0..nn.size)
            
            if(tip)
              tipe="#{tipe}#{nn[t]}";
            end
            if(nn[t]=="/")
              tip=true;
            end
          end

          errores="";
          abortar=false;

          if(tipe!=formatoO)
            bitacora "Archivo no compatible, debe ser de tipo #{formatoO}"
            errores="#{errores}Archivo no compatible, debe ser de tipo #{formatoO}\n"
            abortar=true;
          end
          tamA=(0.000976562*(archivo.size));
          if (tamA>tamO)
            abortar=true;
            bitacora "Archivo #{tamA} KB sobrepasa el tamano establecido #{tamO} KB"
            errores="#{errores}Archivo #{tamA} KB sobrepasa el tamano establecido #{tamO} KB\n"
          end

          if(Time.now>fecha_tope)
            abortar=true;
            bitacora "Ya paso la fecha limite #{fecha_tope}"
            errores="#{errores}Ya paso la fecha limite #{fecha_tope}\n"
          end
          if (abortar)
            flash[:error2]=errores;
            redirect_to :action => "bienvenida" , :controller => "principal"
            return false
          end

         
        else
          flash[:error2]="No puede existir una entrega vacia";
          redirect_to :action => "bienvenida" , :controller => "principal"
          return false
        end


        entregable_integrantes=Integer(session[:usuario].cedula)
        entrega_id=Integer(params[:entrega_id])
        numero_integrantes=Integer(params[:entregable][:numero_integrantes])
      
        
        @entregableN=Entregable.new
        @entregableN.grupo_nro=nGrupo
        @entregableN.entrega_id=entrega_id
        @entregableN.estudiante_cedula_entrego=entregable_integrantes
        @entregableN.fecha_hora=Time.now
        max_version=Entregable.where(:entrega_id =>entrega_id,:grupo_nro => nGrupo).maximum("version").to_i
        if(max_version==nil)
          max_version=1
        else
          max_version=max_version+1
        end

        if(max_version==limiteO)
          mensaje="Recuerda que esta es tu ultima version a entregar"
        end
        if(max_version>limiteO)
          flash[:error2]="Lo sentimos has excedido el numero de versiones a entregar";
          redirect_to :action => "bienvenida" , :controller => "principal"
          return false
        end
        
        @entregableN.version=max_version

        @entregableN.save
        bitacora "El estudiante #{entregable_integrantes} almaceno un Entregable a las #{@entregableN.fecha_hora} perteneciente al grupo #{nGrupo} de la entrega #{entrega_id}"
        @entregableAN.version=@entregableN.version
        @entregableAN.save
        bitacora "Se guardo el archivo #{archivo} perteneciente a la entrega #{entrega_id} del grupo #{nGrupo}"
        #Correoo
        CrearEntregable.correo_crear_entregable(entregable_integrantes,@entregableN.estudiante_cedula_entrego,nGrupo,@entregableAN.nombre,@entregableN.fecha_hora)
        unless(params[:integrantes].blank?)
          for x in (0..cantidad-1)

              integrantes=Integer(params[:integrantes][x])
              CrearEntregable.correo_crear_entregable(integrantes,@entregableN.estudiante_cedula_entrego,nGrupo,@entregableAN.nombre,@entregableN.fecha_hora)
            
          end
        end
        
      end

    
    #No tiene grupo
    
    else
      
      entregable_integrantes=Integer(session[:usuario].cedula)
      
      if params[:entregable][:numero_integrantes].empty?
        bitacora "Faltan Parametros"  
        flash[:error2]="Debe introducir el numero de integrantes"
        redirect_to :action=>"bienvenida",:controller=>"principal"
        return
      end
      numero_integrantes=Integer(params[:entregable][:numero_integrantes])
    #Verificar que vean la materia y tengan esa entrega

    #Materia y seccion de la entrega

      materia_entrega=EntregaSeccion.where(:entrega_id => entrega_id.to_i)
      no_cursa=true;
      errores="";
      #MAteria y seccion del integrante y de la entrega
      i=0
      nop=false
      ced=90909090;

      if(!params[:integrantes].blank?)
        params[:integrantes].each do |integrante|
          ced=integrante;
          materia_entrega.each do |materia_sec|

            mate=materia_sec.materia_id
            sec=materia_sec.seccion_nombre
           
            unless Estudiante.cursa(integrante,mate,sec).blank?
            #Alguno del grupo no tenia asignada la entrega
              
              no_cursa=false;
              
            end

          end
          if (no_cursa)
            no_cursa=true
            nop=true
            bitacora "El estudiante #{ced} no tiene asignada la entrega #{entrega_id}"
            errores33="El estudiante #{integrante} no tiene asignada la entrega #{entrega_id}\n"
            errores="#{errores}\n #{errores33}"
          end

          
        end
        if(no_cursa)
          flash[:error2]=errores;
          redirect_to :action => "bienvenida" , :controller => "principal"
          return false
        end
      end
      #Comienzo y verifico archivo
      archivo=params[:entregable][:archivo]
      unless archivo.blank?

        @entregableAN=EntregableArchivo.new
        
        @entregableAN.entrega_id=entrega_id
        @entregableAN.archivo=archivo.read
        @entregableAN.tipo=archivo.content_type
        @entregableAN.nombre=archivo.original_filename

      
        tip=false;
        tipe="";
        nn = archivo.content_type
        for t in (0..nn.size)
          
          if(tip)
            tipe="#{tipe}#{nn[t]}";
          end
          if(nn[t]=="/")
            tip=true;
          end
        end

        errores="";
        abortar=false;

        if(tipe!=formatoO)
          bitacora "Archivo no compatible, debe ser de tipo #{formatoO}"
          errores="#{errores}Archivo no compatible, debe ser de tipo #{formatoO}\n"
          abortar=true;
        end
        tamA=(0.000976562*(archivo.size));
        if (tamA>tamO)
          abortar=true;
          bitacora "Archivo #{tamA} KB sobrepasa el tamano establecido #{tamO} KB"
          errores="#{errores}Archivo #{tamA} KB sobrepasa el tamano establecido #{tamO} KB\n"
        end

        if(Time.now>fecha_tope)
          abortar=true;
          bitacora "Ya paso la fecha limite #{fecha_tope}"
          errores="#{errores}Ya paso la fecha limite #{fecha_tope}\n"
        end
        if (abortar)
          flash[:error2]=errores;
          redirect_to :action => "bienvenida" , :controller => "principal"
          return false
        end

         
      else
        flash[:error2]="No puede existir una entrega vacia";
        redirect_to :action => "bienvenida" , :controller => "principal"
        return false
      end
      @grupoS = EstudianteGrupo.new
      @grupoS.estudiante_cedula=entregable_integrantes
      @grupoS.entrega_id=entrega_id

      nGrupo=EstudianteGrupo.maximum(:grupo_nro)
      if(nGrupo.blank?)
        nGrupo=0;
      end
      nGrupo=nGrupo+1
      @grupoS.grupo_nro=nGrupo
      @nuevoGrupo = Grupo.new
      @nuevoGrupo.entrega_id=entrega_id
      @nuevoGrupo.nro=nGrupo
      @nuevoGrupo.save
      @grupoS.save
      bitacora "Se almaceno el integrante #{entregable_integrantes} perteneciente al grupo #{nGrupo} de la entrega #{entrega_id}"
      bitacora "Se almaceno el nuevo grupo #{nGrupo} de la entrega #{entrega_id}"

      if(!params[:integrantes].blank?)
        params[:integrantes].each do |integrantes|

            
            @NgrupoS = EstudianteGrupo.new
            @NgrupoS.estudiante_cedula=integrantes
            @NgrupoS.grupo_nro=nGrupo
            @NgrupoS.entrega_id=entrega_id
            bitacora "Se almaceno el integrante #{integrantes} perteneciente al grupo #{nGrupo} de la entrega #{entrega_id}"
            @NgrupoS.save
          
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
      @entregableAN.grupo_nro=nGrupo
      @entregableAN.version=@entregableN.version
      @entregableAN.save
      bitacora "Se guardo el archivo #{archivo} perteneciente a la entrega #{entrega_id} del grupo #{nGrupo}"
      #Correoo
        CrearEntregable.correo_crear_entregable(entregable_integrantes,@entregableN.estudiante_cedula_entrego,nGrupo,@entregableAN.nombre,@entregableN.fecha_hora)
        unless(params[:integrantes].blank?)
          for x in (0..cantidad-1)

              integrantes=Integer(params[:integrantes][x])
              CrearEntregable.correo_crear_entregable(integrantes,@entregableN.estudiante_cedula_entrego,nGrupo,@entregableAN.nombre,@entregableN.fecha_hora)
            
          end
        end
   
      
      
    end
    flash[:exito]="#{mensaje} Entrega realizada con exito"
    redirect_to :action =>'bienvenida',:controller =>"principal"
  end
end