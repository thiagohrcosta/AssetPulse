SEED_PASSWORD = "password123".freeze

srand(20260817)

# ----------------------------------------------------------------------
# Small helpers
# ----------------------------------------------------------------------

VIN_CHARS = (("A".."Z").to_a + ("0".."9").to_a - %w[I O Q]).freeze

# Deterministic, not `rand`-based: `find_or_create_by!(vin: ...)` only runs
# its block for brand-new records, so on a second `db:seed` run fewer
# `rand` calls happen upstream (existing companies/users skip their
# random-attribute blocks entirely) and the *global* random sequence would
# drift, handing this call a different VIN than last time and duplicating
# host units instead of finding them. Seeding a private RNG from a stable
# (company_index, unit_index) pair keeps the VIN identical run over run
# regardless of what else did or didn't consume randomness first.
def deterministic_vin(company_index, unit_index)
  rng = Random.new((company_index * 1000) + unit_index)
  Array.new(17) { VIN_CHARS[rng.rand(VIN_CHARS.length)] }.join
end

# Same reasoning as `deterministic_vin` above: how many host units a
# company gets must not depend on the global `rand` sequence, or a company
# could grow a few extra vehicles on every `db:seed` run.
def host_unit_count_for(company_index)
  Random.new(company_index + 90_000).rand(10..20)
end

# A point in time `days_ago` days before now.
def days_ago(days)
  Time.current - days.days
end

# Caps `desired_days` so that `reference_time + desired_days.days` never
# lands in the future (with a day of slack) — needed because some part
# types have a `typical_lifespan_days` long enough that a naive "install
# date + expected lifespan" would occasionally overshoot "today".
def bounded_days_since(reference_time, desired_days)
  max_days = ((Time.current - 1.day - reference_time) / 1.day).floor
  [ [ desired_days, max_days ].min, 1 ].max
end

def weighted_sample(weighted_options)
  target = rand * weighted_options.sum { |_value, weight| weight }
  cumulative = 0
  weighted_options.each do |value, weight|
    cumulative += weight
    return value if target <= cumulative
  end
  weighted_options.last.first
end

# ----------------------------------------------------------------------
# Reference data
# ----------------------------------------------------------------------

PART_TYPE_DEFINITIONS = {
  "brake_pad" => 545,
  "brake_rotor" => 1095,
  "battery" => 1460,
  "alternator" => 2555,
  "spark_plug" => 1095,
  "air_filter" => 365,
  "oil_filter" => 180,
  "tire" => 1095,
  "water_pump" => 2190,
  "shock_absorber" => 1825
}.freeze

MANUFACTURERS_BY_PART_TYPE = {
  "brake_pad" => %w[Brembo Akebono Bosch],
  "brake_rotor" => %w[Brembo Akebono Bosch],
  "battery" => %w[Bosch Duracell Optima],
  "alternator" => [ "Bosch", "Denso", "Mitsubishi Electric" ],
  "spark_plug" => %w[NGK Denso Champion],
  "air_filter" => [ "Fram", "Mann-Filter", "Bosch" ],
  "oil_filter" => [ "Fram", "Mann-Filter", "Bosch" ],
  "tire" => %w[Michelin Goodyear Bridgestone],
  "water_pump" => %w[Gates Aisin],
  "shock_absorber" => %w[Monroe KYB]
}.freeze

TYPE_PREFIXES = {
  "brake_pad" => "BP", "brake_rotor" => "BR", "battery" => "BA", "alternator" => "AL",
  "spark_plug" => "SP", "air_filter" => "AF", "oil_filter" => "OF", "tire" => "TI",
  "water_pump" => "WP", "shock_absorber" => "SA"
}.freeze

MANUFACTURER_PREFIXES = {
  "Brembo" => "BRM", "Akebono" => "AKB", "Bosch" => "BSH", "Duracell" => "DUR",
  "Optima" => "OPT", "Denso" => "DEN", "Mitsubishi Electric" => "MEL", "NGK" => "NGK",
  "Champion" => "CHM", "Fram" => "FRM", "Mann-Filter" => "MNF", "Michelin" => "MCH",
  "Goodyear" => "GDY", "Bridgestone" => "BRS", "Gates" => "GAT", "Aisin" => "ASN",
  "Monroe" => "MON", "KYB" => "KYB"
}.freeze

VEHICLE_MODELS = [
  "Toyota Corolla 2019", "Toyota Camry 2021", "Honda Civic 2020",
  "Ford F-150 2018", "Ford Transit 2022", "Chevrolet Silverado 2021",
  "Mercedes C300 2020", "Mercedes Sprinter 2021", "BMW 320i 2019",
  "Nissan Sentra 2022", "Hyundai Elantra 2020", "Jeep Wrangler 2021",
  "Volkswagen Jetta 2019", "RAM 1500 2020", "Freightliner Cascadia 2022"
].freeze

FIRST_NAMES = %w[
  James Maria John Patricia Robert Linda Michael Barbara William Elizabeth
  David Jennifer Richard Susan Joseph Jessica Thomas Sarah Charles Karen
].freeze

LAST_NAMES = %w[
  Smith Johnson Williams Brown Jones Garcia Miller Davis Rodriguez Martinez
  Hernandez Lopez Gonzalez Wilson Anderson Taylor Moore Jackson Martin Lee
].freeze

US_LOCATIONS = [
  { city: "Chicago", state: "IL", zip: 60601 },
  { city: "Dallas", state: "TX", zip: 75201 },
  { city: "Atlanta", state: "GA", zip: 30301 },
  { city: "Denver", state: "CO", zip: 80201 },
  { city: "Phoenix", state: "AZ", zip: 85001 },
  { city: "Columbus", state: "OH", zip: 43201 },
  { city: "Portland", state: "OR", zip: 97201 },
  { city: "Charlotte", state: "NC", zip: 28201 },
  { city: "Nashville", state: "TN", zip: 37201 },
  { city: "Kansas City", state: "MO", zip: 64101 }
].freeze

STREET_NAMES = [
  "Industrial Pkwy", "Commerce Dr", "Freight Ave", "Distribution Blvd",
  "Logistics Way", "Harbor Rd", "Fleet St", "Depot Ln"
].freeze

COMPANY_DEFINITIONS = [
  { name: "Northline Logistics", type: "fleet_operator", plan: "premium" },
  { name: "Cedar Valley Transport", type: "fleet_operator", plan: "premium" },
  { name: "Summit Fleet Services", type: "fleet_operator", plan: "basic" },
  { name: "Harborview Freight", type: "fleet_operator", plan: "premium" },
  { name: "Redwood Transit Group", type: "fleet_operator", plan: "basic" },
  { name: "Pinnacle Auto Solutions", type: "fleet_operator", plan: "premium" },
  { name: "Meridian Logistics Partners", type: "fleet_operator", plan: "basic" },
  { name: "Ironclad Fleet Management", type: "fleet_operator", plan: "premium" },
  { name: "AutoTech Repair Co.", type: "repair_shop", plan: "basic" },
  { name: "Trailhead Motor Works", type: "repair_shop", plan: "basic" }
].freeze

# The chronic manufacturing defect at the center of this dataset (see
# section 6 of .agents/create-products.md): ~35 of these alternators fail
# with `replaced_defect` in a tight 700-760 day window, spread across
# several otherwise-unrelated fleet companies, plus a handful still active
# and approaching that window.
CLUSTER_PART_TYPE = "alternator"
CLUSTER_MANUFACTURER = "Denso"
CLUSTER_MODEL = "AL-4400"
CLUSTER_FAILED_COUNT = 35
CLUSTER_ACTIVE_COUNT = 9

serial_sequence = 0

def format_serial(sequence, part_type, manufacturer)
  format("%s-%s-%06d", TYPE_PREFIXES.fetch(part_type), MANUFACTURER_PREFIXES.fetch(manufacturer), sequence)
end

def random_address
  location = US_LOCATIONS.sample
  {
    address_zip_code: location[:zip] + rand(0..99),
    address_street: STREET_NAMES.sample,
    address_number: rand(100..9999),
    address_city: location[:city],
    address_state: location[:state],
    address_complement: rand < 0.3 ? "Suite #{rand(100..499)}" : nil
  }
end

def company_email_domain(company_name)
  company_name.downcase.gsub(/[^a-z0-9]/, "")
end

ActiveRecord::Base.transaction do
  # ----------------------------------------------------------------------
  # Plans (metadata cache — no Stripe calls here, see StripePlanSync for
  # that; stripe_product_id/stripe_price_id stay nil until that task runs)
  # ----------------------------------------------------------------------
  plans = {
    "basic" => Plan.find_or_create_by!(slug: "basic") do |plan|
      plan.name = "Basic"
      plan.amount_cents = 4_999
      plan.currency = "usd"
      plan.interval = "month"
      plan.ai_enabled = false
    end,
    "premium" => Plan.find_or_create_by!(slug: "premium") do |plan|
      plan.name = "Premium with AI"
      plan.amount_cents = 8_999
      plan.currency = "usd"
      plan.interval = "month"
      plan.ai_enabled = true
    end
  }

  # ----------------------------------------------------------------------
  # Platform admin — no company
  # ----------------------------------------------------------------------
  User.find_or_create_by!(email: "admin@assetpulse.io") do |user|
    user.password = SEED_PASSWORD
    user.full_name = "AssetPulse Platform Admin"
    user.document_number = "SEED-PLATFORM-ADMIN"
    user.access = :admin
    user.assign_attributes(random_address)
  end

  # ----------------------------------------------------------------------
  # Companies, their owning (company_admin) user, and their subscription
  # ----------------------------------------------------------------------
  companies = COMPANY_DEFINITIONS.each_with_index.map do |definition, index|
    first_name = FIRST_NAMES.sample
    last_name = LAST_NAMES.sample
    domain = company_email_domain(definition[:name])

    owner = User.find_or_create_by!(email: "admin@#{domain}.com") do |user|
      user.password = SEED_PASSWORD
      user.full_name = "#{first_name} #{last_name}"
      user.document_number = format("SEED-OWNER-%03d", index + 1)
      user.access = :company_admin
      user.assign_attributes(random_address)
    end

    company = Company.find_or_create_by!(name: definition[:name]) do |c|
      c.user = owner
      c.company_type = definition[:type]
      c.registration_number = format("REG-%06d", index + 1)
      c.assign_attributes(random_address)
    end

    Subscription.find_or_create_by!(company: company) do |subscription|
      subscription.plan = plans.fetch(definition[:plan])
      subscription.status = "active"
      subscription.current_period_end = 1.month.from_now
    end

    company
  end

  fleet_companies = companies.select(&:fleet_operator?)

  # ----------------------------------------------------------------------
  # Part type references
  # ----------------------------------------------------------------------
  PART_TYPE_DEFINITIONS.each do |part_type, typical_lifespan_days|
    PartTypeReference.find_or_create_by!(part_type: part_type) do |ref|
      ref.typical_lifespan_days = typical_lifespan_days
    end
  end
  part_type_refs = PartTypeReference.all.index_by(&:part_type)

  # ----------------------------------------------------------------------
  # Host units — fleet companies only, 10-20 vehicles each
  # ----------------------------------------------------------------------
  host_units_by_company = fleet_companies.each_with_index.each_with_object({}) do |(company, company_index), memo|
    memo[company.id] = Array.new(host_unit_count_for(company_index)) do |unit_index|
      HostUnit.find_or_create_by!(vin: deterministic_vin(company_index, unit_index)) do |host_unit|
        host_unit.company = company
        host_unit.description = VEHICLE_MODELS.sample
      end
    end
  end
  all_host_units = host_units_by_company.values.flatten

  puts "Reference data ready: #{Company.count} companies, #{User.count} users, " \
       "#{PartTypeReference.count} part types, #{HostUnit.count} host units."

  # ----------------------------------------------------------------------
  # Parts & lifecycle events
  #
  # Not idempotent at this granularity — wipe and regenerate every run so
  # the chronic-defect cluster's proportions stay exact instead of
  # accumulating duplicates across `rails db:seed` calls.
  # ----------------------------------------------------------------------
  LifecycleEvent.delete_all
  Part.delete_all

  started_at = Time.current
  parts_rows = []
  events_by_serial = Hash.new { |hash, key| hash[key] = [] }

  build_first_install_type = -> { rand < 0.7 ? "factory_original" : "aftermarket_new" }

  # -- Regular population: every host unit tracks 4-7 parts -------------
  all_host_units.each do |host_unit|
    company = host_unit.company

    rand(4..7).times do
      part_type = PART_TYPE_DEFINITIONS.keys.sample
      manufacturer = MANUFACTURERS_BY_PART_TYPE.fetch(part_type).sample
      model = format("%s-%03d", manufacturer[0, 2].upcase, rand(100..999))
      serial_sequence += 1
      serial_number = format_serial(serial_sequence, part_type, manufacturer)
      typical_lifespan = PART_TYPE_DEFINITIONS.fetch(part_type)

      scenario = weighted_sample(
        [
          [ :only_installed, 60 ],
          [ :replaced_wear, 20 ],
          [ :maintenance_ongoing, 8 ],
          [ :reassigned, 5 ]
        ]
      )

      events = []
      final_status = "installed"
      final_host_unit = host_unit
      final_company = company

      case scenario
      when :only_installed
        installed_at = days_ago(rand(30..2000))
        events << { event_type: "installed", installation_type: build_first_install_type.call,
                    occurred_at: installed_at, age_at_event_days: 0, host_unit: host_unit, company: company }

      when :replaced_wear
        installed_at = days_ago(rand(5..2185))
        wear_age = bounded_days_since(installed_at, (typical_lifespan * rand(0.8..1.2)).round)
        wear_at = installed_at + wear_age.days

        events << { event_type: "installed", installation_type: build_first_install_type.call,
                    occurred_at: installed_at, age_at_event_days: 0, host_unit: host_unit, company: company }
        events << { event_type: "replaced_wear", installation_type: nil,
                    occurred_at: wear_at, age_at_event_days: wear_age, host_unit: host_unit, company: company }

        final_status = "removed"
        final_host_unit = nil

      when :maintenance_ongoing
        installed_at = days_ago(rand(5..2185))
        maintenance_age = bounded_days_since(installed_at, rand(60..800))
        maintenance_at = installed_at + maintenance_age.days

        events << { event_type: "installed", installation_type: build_first_install_type.call,
                    occurred_at: installed_at, age_at_event_days: 0, host_unit: host_unit, company: company }
        events << { event_type: "maintenance", installation_type: nil,
                    occurred_at: maintenance_at, age_at_event_days: maintenance_age, host_unit: host_unit, company: company }

      when :reassigned
        installed_at = days_ago(rand(5..2185))
        wear_age = bounded_days_since(installed_at, (typical_lifespan * rand(0.8..1.2)).round)
        wear_at = installed_at + wear_age.days

        events << { event_type: "installed", installation_type: build_first_install_type.call,
                    occurred_at: installed_at, age_at_event_days: 0, host_unit: host_unit, company: company }
        events << { event_type: "replaced_wear", installation_type: nil,
                    occurred_at: wear_at, age_at_event_days: wear_age, host_unit: host_unit, company: company }

        reassign_gap = bounded_days_since(wear_at, rand(10..90))
        reassign_at = wear_at + reassign_gap.days
        new_host_unit = (all_host_units - [ host_unit ]).sample
        events << { event_type: "reassigned", installation_type: "aftermarket_refurbished",
                    occurred_at: reassign_at, age_at_event_days: 0,
                    host_unit: new_host_unit, company: new_host_unit.company }

        if rand < 0.4
          scrap_gap = bounded_days_since(reassign_at, rand(30..500))
          scrap_at = reassign_at + scrap_gap.days
          events << { event_type: "scrapped", installation_type: nil,
                      occurred_at: scrap_at, age_at_event_days: scrap_gap,
                      host_unit: nil, company: new_host_unit.company }
          final_status = "scrapped"
          final_host_unit = nil
          final_company = new_host_unit.company
        else
          final_status = "installed"
          final_host_unit = new_host_unit
          final_company = new_host_unit.company
        end
      end

      parts_rows << {
        serial_number: serial_number,
        part_type_reference_id: part_type_refs.fetch(part_type).id,
        host_unit_id: final_host_unit&.id,
        company_id: final_company.id,
        manufacturer: manufacturer,
        model: model,
        status: final_status,
        created_at: Time.current,
        updated_at: Time.current
      }
      events_by_serial[serial_number] = events
    end
  end

  # -- Chronic defect cluster (section 6) --------------------------------
  cluster_companies = fleet_companies.sample(6)
  failed_counts = Array.new(6, CLUSTER_FAILED_COUNT / 6)
  (CLUSTER_FAILED_COUNT % 6).times { |i| failed_counts[i] += 1 }
  active_counts = Array.new(6, CLUSTER_ACTIVE_COUNT / 6)
  (CLUSTER_ACTIVE_COUNT % 6).times { |i| active_counts[i] += 1 }

  cluster_companies.each_with_index do |company, index|
    needed = failed_counts[index] + active_counts[index]
    cluster_host_units = host_units_by_company.fetch(company.id).sample(needed)

    cluster_host_units.each_with_index do |host_unit, unit_index|
      failed = unit_index < failed_counts[index]
      serial_sequence += 1
      serial_number = format_serial(serial_sequence, CLUSTER_PART_TYPE, CLUSTER_MANUFACTURER)

      events = []
      if failed
        age = rand(700..760)
        installed_at = days_ago(rand(760..2185))
        fail_at = installed_at + age.days
        events << { event_type: "installed", installation_type: build_first_install_type.call,
                    occurred_at: installed_at, age_at_event_days: 0, host_unit: host_unit, company: company }
        events << { event_type: "replaced_defect", installation_type: nil,
                    occurred_at: fail_at, age_at_event_days: age, host_unit: host_unit, company: company }
        final_status = "scrapped"
        final_host_unit = nil
      else
        installed_at = days_ago(rand(650..700))
        events << { event_type: "installed", installation_type: build_first_install_type.call,
                    occurred_at: installed_at, age_at_event_days: 0, host_unit: host_unit, company: company }
        final_status = "installed"
        final_host_unit = host_unit
      end

      parts_rows << {
        serial_number: serial_number,
        part_type_reference_id: part_type_refs.fetch(CLUSTER_PART_TYPE).id,
        host_unit_id: final_host_unit&.id,
        company_id: company.id,
        manufacturer: CLUSTER_MANUFACTURER,
        model: CLUSTER_MODEL,
        status: final_status,
        created_at: Time.current,
        updated_at: Time.current
      }
      events_by_serial[serial_number] = events
    end
  end

  Part.insert_all!(parts_rows)
  part_ids_by_serial = Part.where(serial_number: parts_rows.map { |row| row[:serial_number] })
    .pluck(:serial_number, :id).to_h

  events_rows = events_by_serial.flat_map do |serial_number, events|
    part_id = part_ids_by_serial.fetch(serial_number)
    events.map do |event|
      {
        part_id: part_id,
        host_unit_id: event[:host_unit]&.id,
        company_id: event[:company].id,
        event_type: event[:event_type],
        installation_type: event[:installation_type],
        occurred_at: event[:occurred_at],
        age_at_event_days: event[:age_at_event_days],
        created_at: Time.current,
        updated_at: Time.current
      }
    end
  end
  LifecycleEvent.insert_all!(events_rows)

  elapsed = Time.current - started_at

  chronic_defect_count = LifecycleEvent
    .joins(:part)
    .where(event_type: "replaced_defect")
    .where(parts: { manufacturer: CLUSTER_MANUFACTURER, model: CLUSTER_MODEL })
    .where(age_at_event_days: 700..760)
    .count

  puts "Seed complete:"
  puts "  Companies: #{Company.count}"
  puts "  Users: #{User.count}"
  puts "  Host units: #{HostUnit.count}"
  puts "  Parts: #{Part.count}"
  puts "  Lifecycle events: #{LifecycleEvent.count}"
  puts "  Chronic defect cluster: #{chronic_defect_count} #{CLUSTER_MANUFACTURER} #{CLUSTER_MODEL} " \
       "failures in the 700-760 day window"
  puts "  Parts + lifecycle events generated in #{elapsed.round(2)}s"
end
