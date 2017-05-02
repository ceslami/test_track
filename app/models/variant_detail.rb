class VariantDetail < ActiveRecord::Base
  belongs_to :split

  has_attached_file :screenshot, AttachmentSettings.storage_settings

  validate :variant_must_exist
  validates :display_name, :description, presence: true

  validates_attachment :screenshot, content_type: { content_type: %r(\Aimage\/.+\z) }, size: { in: 0..AttachmentSettings.max_size }

  def display_name
    super || variant
  end

  def weight
    @weight ||= split.variant_weight(variant)
  end

  def assignment_count
    @assignment_count ||= split.assignment_count_for_variant(variant)
  end

  def retirable?
    weight == 0 && assignment_count > 0
  end

  private

  def variant_must_exist
    errors.add(:base, "Variant does not exist: #{variant}") unless split.has_variant?(variant)
  end
end
