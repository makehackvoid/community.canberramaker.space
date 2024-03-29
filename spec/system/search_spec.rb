# frozen_string_literal: true

describe "Search", type: :system do
  let(:search_page) { PageObjects::Pages::Search.new }
  fab!(:topic)
  fab!(:post) { Fabricate(:post, topic: topic, raw: "This is a test post in a test topic") }
  fab!(:topic2) { Fabricate(:topic, title: "Another test topic") }
  fab!(:post2) { Fabricate(:post, topic: topic2, raw: "This is another test post in a test topic") }

  describe "when using full page search on mobile" do
    before do
      SearchIndexer.enable
      SearchIndexer.index(topic, force: true)
      SearchIndexer.index(topic2, force: true)
    end

    after { SearchIndexer.disable }

    it "works and clears search page state", mobile: true do
      visit("/search")

      search_page.type_in_search("test")
      search_page.click_search_button

      expect(search_page).to have_search_result
      expect(search_page.heading_text).not_to eq("Search")

      search_page.click_home_logo
      expect(search_page).to be_not_active

      page.go_back
      # ensure results are still there when using browser's history
      expect(search_page).to have_search_result

      search_page.click_home_logo
      search_page.click_search_icon

      expect(search_page).to have_no_search_result
      expect(search_page.heading_text).to eq("Search")
    end

    it "navigates search results using J/K keys" do
      visit("/search")

      search_page.type_in_search("test")
      search_page.click_search_button

      expect(search_page).to have_search_result

      results = all(".fps-result")

      page.send_keys("j")
      expect(results.first["class"]).to include("selected")

      page.send_keys("j")
      expect(results.last["class"]).to include("selected")

      page.send_keys("k")
      expect(results.first["class"]).to include("selected")
    end
  end

  describe "when using full page search on desktop" do
    before do
      SearchIndexer.enable
      SearchIndexer.index(topic, force: true)
      SiteSetting.rate_limit_search_anon_user_per_minute = 4
      RateLimiter.enable
    end

    after { SearchIndexer.disable }

    xit "rate limits searches for anonymous users" do
      queries = %w[one two three four]

      visit("/search?expanded=true")

      queries.each do |query|
        search_page.clear_search_input
        search_page.type_in_search(query)
        search_page.click_search_button
      end

      # Rate limit error should kick in after 4 queries
      expect(search_page).to have_warning_message
    end
  end
end
