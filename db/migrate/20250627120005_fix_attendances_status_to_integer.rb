class FixAttendancesStatusToInteger < ActiveRecord::Migration[7.1]
  def up
    # Zet bestaande stringwaarden om naar integer
    execute <<-SQL
      UPDATE attendances SET status = '0' WHERE status = 'aanwezig';
      UPDATE attendances SET status = '1' WHERE status = 'afwezig';
      UPDATE attendances SET status = '0' WHERE status IS NULL OR status = '';
      ALTER TABLE attendances ALTER COLUMN status DROP DEFAULT;
      ALTER TABLE attendances ALTER COLUMN status TYPE integer USING status::integer;
      ALTER TABLE attendances ALTER COLUMN status SET DEFAULT 0;
      ALTER TABLE attendances ALTER COLUMN status SET NOT NULL;
    SQL
  end

  def down
    change_column :attendances, :status, :string, default: '0', null: false
  end
end
