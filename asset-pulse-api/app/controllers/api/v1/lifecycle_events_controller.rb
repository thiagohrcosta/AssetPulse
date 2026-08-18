class Api::V1::LifecycleEventsController < ApplicationController
  include Authenticatable
  include SubscriptionGate

  before_action :set_company
  before_action :set_part
  before_action :set_lifecycle_event, only: [:show, :update, :destroy]

  # GET /api/v1/companies/:company_id/parts/:part_id/lifecycle_events
  def index
    render json: @part.lifecycle_events.chronological.map { |event| event_json(event) }, status: :ok
  end

  # GET /api/v1/companies/:company_id/parts/:part_id/lifecycle_events/:id
  def show
    render json: event_json(@lifecycle_event), status: :ok
  end

  # POST /api/v1/companies/:company_id/parts/:part_id/lifecycle_events
  def create
    return render_invalid_host_unit unless host_unit_id_valid?(lifecycle_event_params[:host_unit_id])

    event = @part.lifecycle_events.new(lifecycle_event_params)
    event.company = @company

    if event.save
      render json: event_json(event), status: :created
    else
      render json: { errors: event.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /api/v1/companies/:company_id/parts/:part_id/lifecycle_events/:id
  def update
    return render_invalid_host_unit unless host_unit_id_valid?(lifecycle_event_params[:host_unit_id])

    if @lifecycle_event.update(lifecycle_event_params)
      render json: event_json(@lifecycle_event), status: :ok
    else
      render json: { errors: @lifecycle_event.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /api/v1/companies/:company_id/parts/:part_id/lifecycle_events/:id
  def destroy
    @lifecycle_event.destroy
    head :no_content
  end

  private

  def set_company
    @company = current_user.companies.find(params[:company_id])
  end

  def set_part
    @part = @company.parts.find(params[:part_id])
  end

  def set_lifecycle_event
    @lifecycle_event = @part.lifecycle_events.find(params[:id])
  end

  def lifecycle_event_params
    params.require(:lifecycle_event).permit(:event_type, :installation_type, :occurred_at, :age_at_event_days, :notes, :host_unit_id)
  end

  # An event's host_unit must belong to the same company the part is
  # currently scoped under — blank is fine (e.g. a scrapped/in-transit event).
  def host_unit_id_valid?(host_unit_id)
    host_unit_id.blank? || @company.host_units.exists?(id: host_unit_id)
  end

  def render_invalid_host_unit
    render json: { errors: ["host_unit_id must belong to this company"] }, status: :unprocessable_entity
  end

  def event_json(event)
    event.as_json(only: [:id, :part_id, :host_unit_id, :company_id, :event_type, :installation_type, :occurred_at, :age_at_event_days, :notes, :created_at, :updated_at])
  end
end
