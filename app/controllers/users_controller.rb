class UsersController < ApplicationController
  def new
  @user = User.new
end

def create
  @user = User.new(params[:user])
  @user.user_type_id = 2
  @user.block = false
  @user.active = false
  
  if @user.save
    UserMailer.welcome_email(@user).deliver
    redirect_to root_path, :notice => "Se ha enviado un correo electronico a #{@user.email} para confirmar su registro"
  else
    render :new
  end
end

def show
   @user = User.find(params[:id])

end

def index
	@user = User.all

	respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @user}
    end
end

def destroy
  @user = User.find(params[:id])
  @user.destroy

  respond_to do |format|
    format.html { redirect_to users_path }
    format.json { head :no_content }
  end
end

def asignartipo
	@user = User.find(params[:id])
	@tipoUsuario = UserType.all
	
end

def edit
  @user = User.find(params[:id])
end

def edit_contrasena
    @user = User.find(params[:id])
    @tipoUsuario = UserType.all 
      
end

def update_contrasena
      @user = User.find(params[:id])
     
      if request.post? 
        if User.authenticate(@user.email, params[:old_password]) == @user
          @user.password = params[:nuevo_password] 
          @user.password_confirmation = params[:password_confirmation] 
          if @user.save 
             redirect_to root_path, message: "cambiaste tu password"
          else 
             
            redirect_to edit_contrasena_path
          end 
        else 
            flash.now[:alert] = 'Passord invalido' 
            redirect_to edit_contrasena_path
        end 
      end 
       
    end

def update
   @user = User.find(params[:id])
    respond_to do |format|
      if @user.update_attributes(params[:user])
        format.html { redirect_to root_path, notice: "El usuario #{@user.name} #{@user.lastname} ha sido actualizado exitosamente." }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
end

def bloquearUsuario
  @user = User.find(params[:id])
  @user.block = false
  
    respond_to do |format|
      if @user.update_attributes(params[:user])
        format.html { redirect_to users_path, notice: "El usuario #{@user.name} #{@user.lastname} ha sido Bloqueado exitosamente." }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end

end

def desbloquearUsuario
  @user = User.find(params[:id])
  @user.block = true
  
    respond_to do |format|
      if @user.update_attributes(params[:user])
        format.html { redirect_to users_path, notice: "El usuario #{@user.name} #{@user.lastname} ha sido debloqueado exitosamente." }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end  
end

def viewactivar
  @user = User.find(params[:id])
  if @user.active == true
    redirect_to root_path
  end
end

def activarUsuario
   @user = User.find(params[:id])
  @user.block = true
  @user.active = true
    respond_to do |format|
      if @user.update_attributes(params[:user])
        format.html { redirect_to root_path, notice: "El usuario #{@user.name} #{@user.lastname} ha sido debloqueado exitosamente." }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end  
end


end
