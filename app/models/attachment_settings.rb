class AttachmentSettings
  include Singleton

  class << self
    delegate :storage_settings, :max_size, to: :instance
  end

  def storage_settings
    if settings[:s3].present?
      { storage: :s3 }.merge(settings[:s3])
    elsif settings[:local].present?
      settings[:local]
    else
      raise "Sorry, we can only configure paperclip with local or s3 storage right now. See attachments.yml for details."
    end
  end

  def max_size
    settings['max_size'].kilobytes
  end

  private

  def settings
    @settings ||= HashWithIndifferentAccess.new(YAML.load(interpolated_settings_file)[Rails.env])
  end

  def interpolated_settings_file
    ERB.new(File.read(Rails.root.join('config/attachments.yml'))).result
  end
end
