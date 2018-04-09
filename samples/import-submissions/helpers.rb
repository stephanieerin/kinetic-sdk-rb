
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
