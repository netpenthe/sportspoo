class AddAttachmentIcsToImports < ActiveRecord::Migration
  def self.up
    change_table :imports do |t|
      t.attachment :ics
    end
  end

  def self.down
    drop_attached_file :imports, :ics
  end
end
