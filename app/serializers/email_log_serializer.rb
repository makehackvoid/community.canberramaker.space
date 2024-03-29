# frozen_string_literal: true

class EmailLogSerializer < ApplicationSerializer
  include EmailLogsMixin

  attributes :cc_addresses,
             :post_id,
             :reply_key,
             :bounced,
             :has_bounce_key,
             :smtp_transaction_response

  has_one :user, serializer: BasicUserSerializer, embed: :objects

  def cc_addresses
    return if object.cc_addresses.blank?
    object.cc_addresses_split
  end
  def include_reply_key?
    reply_keys = @options[:reply_keys]
    reply_keys.present? && reply_keys[[object.post_id, object.user_id]]
  end

  def reply_key
    @options[:reply_keys][[object.post_id, object.user_id]].delete("-")
  end

  def has_bounce_key
    object.bounce_key.present?
  end
end
