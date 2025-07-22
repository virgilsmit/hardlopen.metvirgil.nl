class UpdateAttendancesForTrainingSessions < ActiveRecord::Migration[7.1]
  def change
    # Voeg training_session_id toe als het nog niet bestaat (bijv. als dit de eerste keer is dat we de tabel goed opzetten)
    # Of als de tabel al bestaat maar training_id nog niet hernoemd is.
    # We gaan ervan uit dat als training_id bestaat, dit de kolom is die we willen hernoemen.
    # Als training_session_id al bestaat, doen we niets met hernoemen/toevoegen van de kolom zelf.

    unless column_exists?(:attendances, :training_session_id)
      if column_exists?(:attendances, :training_id)
        rename_column :attendances, :training_id, :training_session_id
      else
        # Als noch training_id noch training_session_id bestaat, voegen we training_session_id toe.
        # Dit zou niet moeten gebeuren als de vorige migraties correct waren, maar voor de zekerheid.
        add_reference :attendances, :training_session, null: false, foreign_key: true
      end
    end

    # Zorg ervoor dat de foreign key correct is ingesteld, zelfs als de kolom al bestond.
    # Verwijder eerst een mogelijke oude foreign key op training_id als die nog bestaat.
    if foreign_key_exists?(:attendances, :trainings, column: :training_session_id) # Check met oude tabelnaam
       remove_foreign_key :attendances, :trainings, column: :training_session_id
    end
    # Verwijder ook als de foreign key per ongeluk naar de verkeerde kolom wijst
    if foreign_key_exists?(:attendances, column: :training_session_id)
      fk = foreign_keys(:attendances).find { |f| f.column == "training_session_id" }
      remove_foreign_key :attendances, column: :training_session_id if fk && fk.to_table != "training_sessions"
    end

    # Voeg de correcte foreign key toe als deze nog niet bestaat of incorrect is
    unless foreign_key_exists?(:attendances, :training_sessions, column: :training_session_id)
      add_foreign_key :attendances, :training_sessions, column: :training_session_id
    end

    # Status conversie is al gedaan door de nieuwe migratie, dus overslaan

    # Non-null constraints
    user_id_column = columns(:attendances).find { |c| c.name == 'user_id' }
    if user_id_column && user_id_column.null
      change_column_null :attendances, :user_id, false
    end

    training_session_id_column = columns(:attendances).find { |c| c.name == 'training_session_id' }
    if training_session_id_column && training_session_id_column.null
      change_column_null :attendances, :training_session_id, false
    end

    # Indexen
    add_index :attendances, :status unless index_exists?(:attendances, :status)

    # Unieke index op user_id en training_session_id
    # Verwijder eerst een mogelijke oude index op user_id en training_id
    if index_exists?(:attendances, [:user_id, :training_id], name: 'index_attendances_on_user_id_and_training_id')
      remove_index :attendances, name: 'index_attendances_on_user_id_and_training_id'
    end
    # Verwijder ook een niet-unieke index als die bestaat op de nieuwe kolommen
    if index_exists?(:attendances, [:user_id, :training_session_id]) && !index_exists?(:attendances, [:user_id, :training_session_id], unique: true)
      remove_index :attendances, [:user_id, :training_session_id]
    end
    add_index :attendances, [:user_id, :training_session_id], unique: true unless index_exists?(:attendances, [:user_id, :training_session_id], unique: true)
  end
end
