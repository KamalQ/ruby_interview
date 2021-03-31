class PatientDataController < ApplicationController

  require 'rest-client'
  require 'json'


  def index

    fetch_data

    # (columns can be name, birthdate, and any other relevant information you feel appropriate

  end


  def parse_info(object, key)
    begin
      value = object[key]
    rescue
      value = ''
    end
    value
  end


  def fetch_data
    url = 'http://hapi.fhir.org/baseR4/Patient?_pretty=true'
    response = RestClient.get(url)
    @raw_json = JSON.parse(response)

    @number_of_patients = @raw_json["entry"].length()
    @average_age = 0
    @less_than_18 = 0
    counter_avg_age = 0
    sum_age = 0

    filter_date = Date.new(1951,1,1)

    @bucket_1 = 0 # 0-18
    @bucket_2 = 0 # 19-30
    @bucket_3 = 0 # 31-50
    @bucket_4 = 0 # 51-65
    @bucket_5 = 0 # 65+

    list_of_names = []
    list_of_birthdate = []
    list_of_ages = []
    list_of_genders = []
    list_of_marital_status = []
    list_of_resource_type = []
    list_of_patient_id = []
    @raw_json["entry"].each do |entry|
      to_add_flag = false
      resource_type = parse_info(entry["resource"],"resourceType")
      patient_id = parse_info(entry["resource"],"id")
      gender = parse_info(entry["resource"],"gender")

      deceased = parse_info(entry["resource"],"deceasedBoolean")
      marital_status = parse_info(entry["resource"],"maritalStatus")
      communication = parse_info(entry["resource"],"communication")
      address = parse_info(entry["resource"],"address")

      begin
        birth_date = parse_info(entry["resource"],"birthDate")
        birth_date = Date.strptime(birth_date, '%Y-%m-%d')

        if birth_date >= filter_date
          to_add_flag = true
        end
      rescue
        birth_date = ''
      end

      if to_add_flag
        begin
          age = ((Time.zone.now - birth_date.to_time) / 1.year.seconds).floor  # calculate difference in seconds; Divide by the # seconds in a year
          counter_avg_age += 1
          sum_age = sum_age + age.to_int

          if age.to_int < 18
            @less_than_18 += 1
          end

          case age
          when 0..18
            @bucket_1 += 1
          when 19..30
            @bucket_2 += 1
          when 31..50
            @bucket_3 += 1
          when 51..65
            @bucket_4 += 1
          else
            @bucket_5 += 1
          end

        rescue
          age = ''
        end

        begin
          first_name = parse_info(entry["resource"]["name"][0],"given")[0]
        rescue
          first_name = ' '
        end

        begin
          last_name = parse_info(entry["resource"]["name"][0],"family")
        rescue
          last_name = ' '
        end

        list_of_ages.append(age)
        list_of_names.append(first_name.to_s + ' ' + last_name.to_s)
        list_of_birthdate.append(birth_date)
        list_of_genders.append(gender)
        list_of_marital_status.append(marital_status)
        list_of_resource_type.append(resource_type)
        list_of_patient_id.append(patient_id)

        print("resource_Type: " + resource_type.to_s)
        print("\n")
        print("patient_id: " + patient_id.to_s)
        print("\n")
        print("first_name: " + first_name.to_s)
        print("\n")
        print("last_name: " + last_name.to_s)
        print("\n")
        print("gender: " + gender.to_s)
        print("\n")
        print("birth_date: " + birth_date.to_s)
        print("\n")
        print("age: " + age.to_s)
        print("\n")
        print("address: " + address.to_s)
        print("\n")
        print("communication: " + communication.to_s)
        print("\n")
        print("deceased: " + deceased.to_s)
        print("\n")
        print("marital_status: " + marital_status.to_s)
        print("\n===================================\n")

      end

    end

    if sum_age != 0
      @average_age = sum_age / counter_avg_age
    end
    print(list_of_names.length())
    print(list_of_names)

    data_frame = Daru::DataFrame.new(
        {
          'Resource Type' => list_of_resource_type,
          'ID' => list_of_patient_id,
          'Patient' => list_of_names,
          'Birthday' => list_of_birthdate,
          'Age' => list_of_ages,
          'Gender' => list_of_genders,
          # 'Marital Status' => list_of_marital_status
        },
        index: [*1..list_of_names.length()]
      )
    @df = data_frame.to_html()

  end


end