class Api::V1::CompaniesController < ApplicationController
  include Authenticatable

  before_action :set_company, only: [:show, :update, :destroy]

  # GET /api/v1/companies
  def index
    render json: current_user.companies.map { |company| company_json(company) }, status: :ok
  end

  # GET /api/v1/companies/:id
  def show
    render json: company_json(@company), status: :ok
  end

  # POST /api/v1/companies
  def create
    company = current_user.companies.new(company_params)

    if company.save
      render json: company_json(company), status: :created
    else
      render json: { errors: company.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /api/v1/companies/:id
  def update
    if @company.update(company_params)
      render json: company_json(@company), status: :ok
    else
      render json: { errors: @company.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /api/v1/companies/:id
  def destroy
    @company.destroy
    head :no_content
  end

  private

  def set_company
    @company = current_user.companies.find(params[:id])
  end

  def company_params
    params.require(:company).permit(
      :name,
      :registration_number,
      :address_zip_code,
      :address_street,
      :address_number,
      :address_city,
      :address_complement,
      :address_state,
      :logo
    )
  end

  def company_json(company)
    company.as_json(except: [:user_id]).merge(
      logo_url: company.logo.attached? ? company.logo.url : nil
    )
  end
end
