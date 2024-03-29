# frozen_string_literal: true

module LimitedEdit
  extend ActiveSupport::Concern

  def edit_time_limit_expired?(user)
    return true if !trusted_with_edits?(user)
    time_limit = user_time_limit(user)
    created_at && (time_limit > 0) && (created_at < time_limit.minutes.ago)
  end

  private

  # TODO: This duplicates some functionality from PostGuardian. This should
  #       probably be checked there instead, because this has nothing to do
  #       with time limits.
  #
  def trusted_with_edits?(user)
    user.trust_level >= SiteSetting.min_trust_to_edit_post ||
      user.in_any_groups?(SiteSetting.edit_post_allowed_groups_map)
  end

  def user_time_limit(user)
    if user.trust_level < 2
      SiteSetting.post_edit_time_limit.to_i
    else
      SiteSetting.tl2_post_edit_time_limit.to_i
    end
  end
end
