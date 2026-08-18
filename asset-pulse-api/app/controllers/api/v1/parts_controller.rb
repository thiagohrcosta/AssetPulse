class Api::V1::PartsController < ApplicationController
  include Authenticatable
  include SubscriptionGate

  before_action :set_company
  before_action :set_part, only: [:show, :update, :destroy]

  # GET /api/v1/companies/:company_id/parts
  #
  # Optional filters: host_unit_id, status, part_type_reference_id.
  def index
    parts = @company.parts
    parts = parts.where(host_unit_id: params[:host_unit_id]) if params[:host_unit_id].present?
    parts = parts.where(status: params[:status]) if params[:status].present?
    parts = parts.where(part_type_reference_id: params[:part_type_reference_id]) if params[:part_type_reference_id].present?

    render json: parts.order(:id).map { |part| part_json(part) }, status: :ok
  end

  # GET /api/v1/companies/:company_id/parts/:id
  def show
    render json: part_json(@part), status: :ok
  end

  # POST /api/v1/companies/:company_id/parts
  def create
    return render_invalid_host_unit unless host_unit_id_valid?(part_params[:host_unit_id])

    part = @company.parts.new(part_params)

    if part.save
      render json: part_json(part), status: :created
    else
      render json: { errors: part.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /api/v1/companies/:company_id/parts/:id
  def update
    return render_invalid_host_unit unless host_unit_id_valid?(part_params[:host_unit_id])

    if @part.update(part_params)
      render json: part_json(@part), status: :ok
    else
      render json: { errors: @part.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /api/v1/companies/:company_id/parts/:id
  def destroy
    @part.destroy
    head :no_content
  end

  private

  def set_company
    @company = current_user.companies.find(params[:company_id])
  end

  def set_part
    @part = @company.parts.find(params[:id])
  end

  def part_params
    params.require(:part).permit(:part_type_reference_id, :host_unit_id, :serial_number, :manufacturer, :model, :status)
  end

  # A part's host_unit must belong to the same company it's being
  # assigned/scoped to — blank is fine (part not currently installed).
  def host_unit_id_valid?(host_unit_id)
    host_unit_id.blank? || @company.host_units.exists?(id: host_unit_id)
  end

  def render_invalid_host_unit
    render json: { errors: ["host_unit_id must belong to this company"] }, status: :unprocessable_entity
  end

  def part_json(part)
    part.as_json(only: [:id, :company_id, :host_unit_id, :part_type_reference_id, :serial_number, :manufacturer, :model, :status, :created_at, :updated_at])
      .merge(part_type: part.part_type, typical_lifespan_days: part.typical_lifespan_days)
  end
end
