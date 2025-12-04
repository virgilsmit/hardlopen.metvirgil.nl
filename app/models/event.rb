class Event < ApplicationRecord
  validates :name, presence: true
  validates :date, presence: true
  
  scope :visible, -> { where(visible: true) }
  scope :published, -> { where(published: true) }
  scope :upcoming, -> { where('date >= ?', Date.today).order(:date) }
  scope :past, -> { where('date < ?', Date.today).order(date: :desc) }
  
  def self.import_from_excel(file_path)
    require 'roo'
    xlsx = Roo::Spreadsheet.open(file_path)
    sheet = xlsx.sheet(0)
    
    # Skip header row, start from row 2
    (2..sheet.last_row).each do |i|
      Event.create!(
        name: sheet.cell(i, 1),
        date: sheet.cell(i, 2),
        location: sheet.cell(i, 3),
        distance: sheet.cell(i, 4),
        organizer: sheet.cell(i, 5),
        url: sheet.cell(i, 6),
        description: sheet.cell(i, 7),
        price: sheet.cell(i, 8),
        registration_deadline: sheet.cell(i, 9),
        visible: true,
        published: true
      )
    end
  end
  
  def past?
    date < Date.today
  end
  
  def upcoming?
    date >= Date.today
  end
  
  def registration_open?
    return true if registration_deadline.nil?
    Date.today <= registration_deadline
  end
end
