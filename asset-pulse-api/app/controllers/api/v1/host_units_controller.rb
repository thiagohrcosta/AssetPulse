class Api::V1::HostUnitsController < ApplicationController
  include Authenticatable
  include SubscriptionGate

  before_action :set_company
  before_action :set_host_unit, only: [:show, :update, :destroy]

  # GET /api/v1/companies/:company_id/host_units
  def index
    render json: @company.host_units.order(:id).map { |host_unit| host_unit_json(host_unit) }, status: :ok
  end

  # GET /api/v1/companies/:company_id/host_units/:id
  def show
    render json: host_unit_json(@host_unit), status: :ok
  end

  # POST /api/v1/companies/:company_id/host_units
  def create
    host_unit = @company.host_units.new(host_unit_params)

    if host_unit.save
      render json: host_unit_json(host_unit), status: :created
    else
      render json: { errors: host_unit.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /api/v1/companies/:company_id/host_units/:id
  def update
    if @host_unit.update(host_unit_params)
      render json: host_unit_json(@host_unit), status: :ok
    else
      render json: { errors: @host_unit.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /api/v1/companies/:company_id/host_units/:id
  def destroy
    @host_unit.destroy
    head :no_content
  end

  private

  def set_company
    @company = current_user.companies.find(params[:company_id])
  end

  def set_host_unit
    @host_unit = @company.host_units.find(params[:id])
  end

  def host_unit_params
    params.require(:host_unit).permit(:vin, :description)
  end

  def host_unit_json(host_unit)
    host_unit.as_json(only: [:id, :company_id, :vin, :description, :created_at, :updated_at])
  end
end
