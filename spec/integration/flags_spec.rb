# frozen_string_literal: true

RSpec.describe PostAction do
  it "triggers the 'flag_reviewed' event when there was at least one flag" do
    admin = Fabricate(:admin, refresh_auto_groups: true)

    post = Fabricate(:post)
    events = DiscourseEvent.track_events { PostDestroyer.new(admin, post).destroy }
    expect(events.map { |e| e[:event_name] }).to_not include(:flag_reviewed)

    flagged_post = Fabricate(:post)
    PostActionCreator.spam(admin, flagged_post)
    events = DiscourseEvent.track_events { PostDestroyer.new(admin, flagged_post).destroy }
    expect(events.map { |e| e[:event_name] }).to include(:flag_reviewed)
  end
end
