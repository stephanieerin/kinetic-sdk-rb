require 'faker'

#--------------------------------------------------------------------------
# HELPER METHODS
#--------------------------------------------------------------------------

# This method takes a string and determines the delimiter (comma, tab...etc)
def find_delimiter(path)
  first_line = File.open(path).first
  return nil unless first_line
  snif = {}
  COMMON_DELIMITERS.each {|delim|snif[delim]=first_line.count(delim)}
  snif = snif.sort {|a,b| b[1]<=>a[1]}
  snif.size > 0 ? snif[0][0][1] : nil
end

# This method returns a valid CE Field given a field name
def build_field_element(name)
  {
    "type" => "field",
    "name" => name,
    "label" => name,
    "key" => "f#{@fieldKey}",
    "defaultValue" => nil,
    "defaultResourceName" => nil,
    "visible" => true,
    "enabled" => true,
    "required" => false,
    "requiredMessage" => nil,
    "omitWhenHidden" => nil,
    "pattern" => nil,
    "constraints" => [],
    "events" => [],
    "renderAttributes" => {},
    "dataType" => "string",
    "renderType" => "text",
    "rows" => 1
  }
end

# This method returns a valid Form given a name and slug
def build_form(name, slug)
  {
    "name" => name,
    "pages" => [
      {
        "elements" => [
          {
            "type" => "button",
            "label" => "Submit",
            "name" => "Submit Button",
            "visible" => true,
            "enabled" => true,
            "renderType" => "submit-page",
            "renderAttributes" => {}
          }
        ],
        "events" => [],
        "name" => "Page 1",
        "renderType" => "submittable",
        "type" => "page"
      }
    ],
    "status" => "Active",
    "slug" => slug
  }
end

# This method returns a form with fields
def build_form_with_fields(name, slug, fields)
  # Build the form
  form = build_form(name, slug)
  # Hold on to the submit button so it can be added at the bottom of the page
  submit_button = form['pages'][0]['elements'].shift
  # Inject the fields
  @fieldKey = 1
  fields.each do |field|
    form['pages'][0]['elements'] << build_field_element(field)
    @fieldKey += 1
  end
  # Add the submit button back to the end of the page
  form['pages'][0]['elements'] << submit_button
  # Return the form
  form
end

# Builds submission data based on the form fields
def build_submission_data(fields)
  Faker::Config.locale = "en-US"
  fields.inject({}) do |data, field|
    case field
    when 'First Name'
      data[field] = Faker::Name.first_name
    when 'Last Name'
      data[field] = Faker::Name.last_name
    when 'Street'
      data[field] = Faker::Address.street_address
    when 'City'
      data[field] = Faker::Address.city
    when 'State'
      data[field] = Faker::Address.state
    when 'Zip'
      data[field] = Faker::Address.zip
    when 'Age'
      data[field] = Faker::Number.between(1, 100)
    when 'Phone'
      data[field] = Faker::PhoneNumber.phone_number
    else
      data[field] = Faker::Lorem.sentence
    end
    data
  end
end

