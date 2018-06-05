class ApplicantsController < ApplicationController
  before_filter :find_applicant, only: [:show, :edit, :update, :destroy]
  
  def index
    @applicants = Applicant.all.order(:created_at).reverse_order
  end
  
  def new
    @applicant = Applicant.new
  end
  
  def create
    @applicant = Applicant.new(applicant_params)
    if @applicant.save
      flash[:success] = "Телеграмма записана в буфер"
      redirect_to applicants_path
    else
      render 'new'
    end
  end
  
  def edit
  end

  def update
    if not @applicant.update_attributes applicant_params
      render :action => :edit
    else
      redirect_to applicants_path
    end
  end
  
  def destroy
    @applicant.destroy
    flash[:success] = "Телеграмма удалена"
    redirect_to applicants_path
  end
  
  private
    def applicant_params
      params.require(:applicant).permit(:telegram)  
    end
    
    def find_applicant
      @applicant = Applicant.find(params[:id])
    end
end
