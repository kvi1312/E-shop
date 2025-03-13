class Product < ApplicationRecord
  belongs_to :category

  has_many_attached :images do |attachable|
    attachable.variant :thumb, resize_to_limit: [ 70, 70 ]
    attachable.variant :medium, resize_to_limit: [ 250, 250 ]
  end

  has_many :stocks
  has_many :order_products

  def as_json(options = {})
    json = super(options)

    if images.attached?
      json['image_urls'] = images.map do |image|
        url_options = Rails.application.config.action_mailer.default_url_options

        {
          original: Rails.application.routes.url_helpers.rails_blob_url(image, **url_options),
          thumb: Rails.application.routes.url_helpers.rails_representation_url(image.variant(:thumb), **url_options),
          medium: Rails.application.routes.url_helpers.rails_representation_url(image.variant(:medium), **url_options)
        }
      end
    else
      json['image_urls'] = []
    end

    json
  end
end