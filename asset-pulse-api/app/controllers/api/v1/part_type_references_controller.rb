class Api::V1::PartTypeReferencesController < ApplicationController
  include Authenticatable

  before_action :set_part_type_reference, only: [:show, :update, :destroy]
  before_action :require_admin!, only: [:create, :update, :destroy]

  # GET /api/v1/part_type_references
  #
  # Global reference/lookup data, not scoped to a company — any
  # authenticated user needs this list to create parts.
  def index
    render json: PartTypeReference.order(:part_type).map { |reference| reference_json(reference) }, status: :ok
  end

  # GET /api/v1/part_type_references/:id
  def show
    render json: reference_json(@part_type_reference), status: :ok
  end

  # POST /api/v1/part_type_references
  #
  # Admin only — this catalog is seeded once and not meant to churn.
  def create
    reference = PartTypeReference.new(part_type_reference_params)

    if reference.save
      render json: reference_json(reference), status: :created
    else
      render json: { errors: reference.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /api/v1/part_type_references/:id
  def update
    if @part_type_reference.update(part_type_reference_params)
      render json: reference_json(@part_type_reference), status: :ok
    else
      render json: { errors: @part_type_reference.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /api/v1/part_type_references/:id
  def destroy
    @part_type_reference.destroy
    head :no_content
  rescue ActiveRecord::DeleteRestrictionError => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  private

  def set_part_type_reference
    @part_type_reference = PartTypeReference.find(params[:id])
  end

  def require_admin!
    render json: { error: "Admin access required." }, status: :forbidden unless current_user.admin?
  end

  def part_type_reference_params
    params.require(:part_type_reference).permit(:part_type, :typical_lifespan_days)
  end

  def reference_json(reference)
    reference.as_json(only: [:id, :part_type, :typical_lifespan_days, :created_at, :updated_at])
  end
end
