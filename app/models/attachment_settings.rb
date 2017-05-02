class AttachmentSettings
  include Singleton

  class << self
    delegate :storage_settings, :max_size, :attachments_enabled?, to: :instance
  end

  def attachments_enabled?
    s3_enabled? || local_enabled?
  end

  def storage_settings
    if s3_enabled?
      s3_settings
    else
      local_settings
    end
  end

  def max_size
    ENV['ATTACHMENT_MAX_SIZE'] || 512.kilobytes
  end

  private

  def s3_enabled?
    storage_strategy == 's3' && s3_settings_valid?
  end

  def local_enabled?
    storage_strategy == 'local'
  end

  def local_settings
    {
      path: ENV['LOCAL_UPLOAD_PATH'] || ':rails_root/public/system/:class/:attachment/:id_partition/:style/:filename'
    }
  end

  def s3_settings
    {
      storage: :s3,
      s3_credentials: {
        access_key_id: ENV['S3_ACCESS_KEY_ID'],
        secret_access_key: ENV['S3_SECRET_ACCESS_KEY']
      },
      bucket: ENV['S3_ATTACHMENT_BUCKET'],
      s3_region: ENV['S3_REGION'] || 'us-east-1',
      s3_permissions: ENV['S3_ATTACHMENT_PERMISSIONS'] || 'private',
      path: ENV['S3_ATTACHMENT_PATH'] || ':class/:attachment/:id_partition/:style/:filename'
    }
  end

  def s3_settings_valid?
    ENV['S3_ACCESS_KEY_ID'].present? && ENV['S3_SECRET_ACCESS_KEY'].present? && ENV['S3_ATTACHMENT_BUCKET'].present?
  end

  def storage_strategy
    ENV['ATTACHMENT_STORAGE']
  end
end
