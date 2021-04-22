class Api::V1::PatientsController < ApiController
  before_action :set_patient, only: %i[update_status]

  def update_status
    if @patient.update(patient_params)
      render json: true
    else
      render json: false
    end
  end

  private

  def set_patient
    @patient = CrAccessData.find_by(prepmod_patient_id: params[:token])
  end

  def patient_params
    params.require(:cr_access_data).permit(:vaccination_status)
  end
end
