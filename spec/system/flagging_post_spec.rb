# frozen_string_literal: true

describe "Flagging post", type: :system do
  fab!(:current_user) { Fabricate(:admin, refresh_auto_groups: true) }
  fab!(:first_post) { Fabricate(:post) }
  fab!(:post_to_flag) { Fabricate(:post, topic: first_post.topic) }

  let(:topic_page) { PageObjects::Pages::Topic.new }
  let(:flag_modal) { PageObjects::Modals::Flag.new }

  before { sign_in(current_user) }

  describe "Using Take Action" do
    it "can select the default action to hide the post, agree with other flags, and reach the flag threshold" do
      other_flag = Fabricate(:flag, post: post_to_flag, user: Fabricate(:moderator))
      other_flag_reviewable =
        Fabricate(:reviewable_flagged_post, target: post_to_flag, created_by: other_flag.user)
      expect(other_flag.reload.agreed_at).to be_nil
      topic_page.visit_topic(post_to_flag.topic)
      topic_page.expand_post_actions(post_to_flag)
      topic_page.click_post_action_button(post_to_flag, :flag)
      flag_modal.choose_type(:off_topic)
      flag_modal.take_action(:agree_and_hide)

      expect(
        topic_page.post_by_number(post_to_flag).ancestor(".topic-post.post-hidden"),
      ).to be_present

      visit "/review/#{other_flag_reviewable.id}"

      expect(page).to have_content(I18n.t("js.review.statuses.approved_flag.title"))
      expect(page).to have_css(".reviewable-meta-data .status .approved")
    end
  end
end
