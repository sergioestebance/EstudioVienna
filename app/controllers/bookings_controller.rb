class BookingsController < ApplicationController
  # GET /bookings
  # GET /bookings.json
  def index
    @bookings = Booking.all
    @bookings_by_date = @bookings.group_by(&:fecha)
    @date = params[:date] ? Date.parse(params[:date]) : Date.today
    
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @bookings }
    end
  end

  # GET /bookings/1
  # GET /bookings/1.json
  def show
    #@booking = Booking.find(params[:id])
    #@booking = Booking.includes(:horas).find(params[:id])
    @booking = Booking.find(params[:id], :include => [ :horas ])

    @assistant = Assistant.where(:booking_id => params[:id] )
    @equipos = Booking.includes(:tools).find(params[:id])  
    @cantidad_horas = 0
    @precio_instrumentos = 0

    #########################

    if @equipos.tools.count != 0 
      @equipos.tools.each do |tool| 
       tool.name
       tool.price_unitary
       @precio_instrumentos = @precio_instrumentos + tool.price_unitary.to_i
      end
    end
    
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @booking }
    end
  end

  # GET /bookings/new
  # GET /bookings/new.json
  def new
    
    #################
    @opcion = "new"
    @boton = "Solicitar reserva"
    #################
    
    @booking = Booking.new
    @rooms = Room.all
    @day = params[:day]
    @month = params[:month]
    @year = params[:year]
    @fecha = "#{@year}-#{@month}-#{@day}"

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @booking }
    end
  end

  # GET /bookings/1/edit
  def edit
    
    #################
    @boton = "Actualizar solicitud"
    @opcion = "update"
    #################
    
    @booking = Booking.find(params[:id])
    @rooms = Room.all
    @day = @booking.fecha.day
    @month = @booking.fecha.month
    @year = @booking.fecha.year
    @fecha = "#{@day}/#{@month}/#{@year}"
    
  end

  # POST /bookings
  # POST /bookings.json
  def create
    @booking = Booking.new(params[:booking])
    @booking.estate = "Solicitado"
    @booking.amount = 0
    @booking.fecha = params[:fecha]
    @booking.user_id = params[:userid]

    respond_to do |format|
      if @booking.save
        format.html { redirect_to booking_path(@booking) }
        format.json { render json: @booking, status: :created, location: @booking }
      else
        format.html { render action: "new" }
        format.json { render json: @booking.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /bookings/1
  # PUT /bookings/1.json
  def update
    @booking = Booking.find(params[:id])

    respond_to do |format|
      if @booking.update_attributes(params[:booking])
        format.html { redirect_to @booking, notice: 'Booking was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @booking.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /bookings/1
  # DELETE /bookings/1.json
  
  def destroy
    @booking = Booking.find(params[:id])
    @booking.destroy

    respond_to do |format|
      format.html { redirect_to bookings_url }
      format.json { head :no_content }
    end
  end

############################################# Solicitudes  ###########################################################

  #definicion que lista todas la solicitudes de reserva realizadas
  def listarSolicitudes
    if current_user
      if current_user.user_type_id == 1
        @bookings = Booking.where(:estate => "Solicitado" ).order(:fecha)
      else
        @bookings = Booking.where(:estate => "Solicitado", :user_id => current_user.id  ).order(:fecha)
      end # fin current_user.user_type_id 
    end # fin current_user
  end

  def cancelarSolicitud
    @booking = Booking.find(params[:id])
    @booking.estate = "Cancelado"    

    respond_to do |format|
      if @booking.update_attributes(params[:booking])
        format.html { redirect_to listarSolicitudes_path, notice: 'Booking was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @booking.errors, status: :unprocessable_entity }
      end
    end
  end

  def confirmarSolicitud
    @booking = Booking.find(params[:id])
    @rooms = Room.all
  end

  def guardarConfirmarSolicitud
    @booking = Booking.find(params[:id])
    @booking.amount = params[:amount]
    @booking.estate = "Confirmado"

    respond_to do |format|
      if @booking.update_attributes(params[:booking])
        format.html { redirect_to listarSolicitudes_path, notice: 'Booking was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @booking.errors, status: :unprocessable_entity }
      end
    end
  end

  ############################################# Reservas  ###########################################################

  def listarReservas
    @bookings   = Booking.where(:estate => "Confirmado" ).order(:fecha)
    @finalizada = Booking.where(:estate => "Finalizado" ).order(:fecha)
    @cancelada  = Booking.where(:estate => "Cancelado" ).order(:fecha)    
  end

  def controlarAsistencia
    @sala = Room.all
    @fecha_actual = Date.today
    @reservas_sala1 =  Booking.where(:room_id => 1, :fecha => @fecha_actual ).order(:fecha)
    @reservas_sala2 =  Booking.where(:room_id => 2, :fecha => @fecha_actual ).order(:fecha)    
  end

  def AsistenciaPresente
    @booking = Booking.find(params[:id])
    @booking.estate = "Asistido"

    respond_to do |format|
      if @booking.update_attributes(params[:booking])
        format.html { redirect_to controlarAsistencia_path, notice: 'Booking was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @booking.errors, status: :unprocessable_entity }
      end
    end    
  end


  def AsistenciaAusente    
    @booking = Booking.find(params[:id])
    @booking.estate = "NoAsistido"

    respond_to do |format|
      if @booking.update_attributes(params[:booking])
        format.html { redirect_to controlarAsistencia_path, notice: 'Booking was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @booking.errors, status: :unprocessable_entity }
      end
    end
  end
  ################################# Asignar equipo y/o Accesorio a reseva  #####################################

 def AsignarTool
    @booking = Booking.find(params[:id])
 end

 def guardarAsignarTools
   
 end


 ################################# Finalizar reserva  #####################################

 def FinalizarReserva
  @booking = Booking.find(params[:id], :include => [ :horas ])
  @equipos = Booking.includes(:tools).find(params[:id])  
  @sala    = Room.find(@booking.room_id)
  @assistant = Assistant.where(:booking_id => params[:id] )
  @cantidad_horas = 0
  @precio_instrumentos = 0

    #########################

    if @equipos.tools.count != 0 
      @equipos.tools.each do |tool| 
       @precio_instrumentos = @precio_instrumentos + tool.price_unitary.to_i
      end
    end


    
 end 
 def guardarFinalizarReserva
    @booking = Booking.find(params[:id])
    @booking.estate = "Finalizado"

    respond_to do |format|
      if @booking.update_attributes(params[:booking])
        format.html { redirect_to controlarAsistencia_path, notice: 'Booking was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @booking.errors, status: :unprocessable_entity }
      end
    end
 end 

end


