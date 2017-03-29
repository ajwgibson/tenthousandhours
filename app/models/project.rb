require 'csv'

class Project < ActiveRecord::Base

  acts_as_paranoid

  include Filterable

  validates :organisation_type, :presence => true
  validates :organisation_name, :presence => true


  ORG_TYPES = [
    "Agency/Charity",
    "Business",
    "Pre-school",
    "Residential centre",
    "School",
  ]


  def self.import(file)

    data = CSV.read(file, headers: :first_row, return_headers: true)

    raise 'Invalid format' if !data.headers.eql?(self.headers)

    ActiveRecord::Base.transaction do

      data.each_with_index do |row, i|

        next if i.zero?

        params = {}
        params['typeform_id']           = row[0]
        params['organisation_type']     = self.organisation_type row
        params['organisation_name']     = self.organisation_name row
        contact_offset = (row[7].eql? '1') ? 0 : 4
        params['contact_name']          = row[8  + contact_offset]
        params['contact_role']          = row[9  + contact_offset]
        params['contact_email']         = row[10 + contact_offset]
        params['contact_phone']         = row[11 + contact_offset]
        params['project_1_summary']     = row[16]
        params['project_1_information'] = row[17]
        params['project_1_under_18']    = row[18].eql? '1'
        params['project_2_summary']     = row[19]
        params['project_2_information'] = row[20]
        params['project_2_under_18']    = row[21].eql? '1'
        params['project_3_summary']     = row[22]
        params['project_3_information'] = row[23]
        params['project_3_under_18']    = row[24].eql? '1'
        params['any_week']              = self.any_week row
        params['july_3']                = !row[25].blank? && !params['any_week']
        params['july_10']               = !row[26].blank? && !params['any_week']
        params['july_17']               = !row[27].blank? && !params['any_week']
        params['july_24']               = !row[28].blank? && !params['any_week']
        params['evenings']              = row[30].eql? '1'
        params['saturday']              = row[31].eql? '1'
        params['notes']                 = row[32]
        params['submitted_at']          = self.parse_submitted_at row[34]

        unless params['contact_phone'].blank? ||
               params['contact_phone'].start_with?('0') then
          params['contact_phone'] = "0#{params['contact_phone']}"
        end

        begin
          Project.where(typeform_id: params['typeform_id']).first_or_initialize.tap do |project|
            project.assign_attributes(params)
            project.save!
          end
        rescue
          raise 'Invalid data'
        end
      end
    end
  end


private

  def self.organisation_type(row)
    row[1] || ''
  end


  def self.organisation_name(row)
    org_type = self.organisation_type(row).downcase
    return row[6] if org_type.eql? 'residential centre'
    return row[5] if org_type.eql? 'business'
    return row[4] if org_type.eql? 'agency/charity'
    return row[3] if org_type.eql? 'school'
    row[2]
  end


  def self.parse_submitted_at(submitted_at)
    if !submitted_at.blank?
      begin
        return DateTime.strptime(submitted_at, '%m/%d/%Y %H:%M')
      rescue ArgumentError
      end
    end
    return nil
  end


  def self.any_week(row)
    !row[29].blank?
  end


  def self.headers
    [
      "#",
      "Please choose the option that best describes your organisation?",
      "Great. What is the name of your pre-school?",
      "Great. What is the name of your school?",
      "Great. What is the name of your Agency/Charity?",
      "Great. What is the name of your Business?",
      "Great. What is the name of your Residential centre?",
      "Will you be the main contact throughout the project?",
      "Great. What is your name?",
      "What is your role within the organisation?",
      "And the best email address to contact you on is?",
      "What would be the best phone number to reach you on?",
      "No problem, who will the contact person be?",
      "What is their role within the organisation?",
      "And the best email address to contact them on is?",
      "What would be the best phone number to reach them on?",
      "Thank you. What is the first of the three projects you would love 10000 hours to complete?",
      "Please include any information you feel would be helpful for us to know at this point about that project.",
      "Is this a job that would be suitable for Under 18's",
      "What is the second project you would love 10000 hours to complete?",
      "Please include any information you feel would be helpful for us to know at this point about that project.",
      "Is this a job that would be suitable for Under 18's",
      "Nearly there! What is the third project you would love 10000 hours to complete?",
      "Please include any information you feel would be helpful for us to know at this point about that project.",
      "Is this a job that would be suitable for Under 18's",
      "3rd - 7th July",
      "10th - 11th July",
      "17th - 21st July",
      "24th - 28th July",
      "No preference",
      "Would there be the option of carrying out the projects in the evenings?",
      "And what about the option of the projects being on a Saturday?",
      "Are there are any additional notes you would like to add or questions you would like to ask, please do so below.",
      "Start Date (UTC)",
      "Submit Date (UTC)",
      "Network ID"
    ]
 end

end
