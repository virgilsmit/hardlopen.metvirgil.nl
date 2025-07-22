class TileAssignment < ApplicationRecord
  validates :role, presence: true
  validates :tile_key, presence: true
  validates :visible, inclusion: { in: [true, false] }
  validates :tile_key, uniqueness: { scope: :role }
  # custom_label: optioneel veld voor aangepaste tegel-titel
end
