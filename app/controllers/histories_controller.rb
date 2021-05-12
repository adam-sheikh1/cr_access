class HistoriesController < ApplicationController
  before_action :set_vaccinations

  def show; end

  private

  def set_vaccinations
    @vaccinations = current_user.vaccination_records
  end
end
