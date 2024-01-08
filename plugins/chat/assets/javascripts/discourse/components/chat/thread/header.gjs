import Component from "@glimmer/component";
import { inject as service } from "@ember/service";
import replaceEmoji from "discourse/helpers/replace-emoji";
import icon from "discourse-common/helpers/d-icon";
import I18n from "discourse-i18n";
import Navbar from "discourse/plugins/chat/discourse/components/chat/navbar";
import ChatThreadHeaderUnreadIndicator from "discourse/plugins/chat/discourse/components/chat/thread/header-unread-indicator";

export default class ChatThreadHeader extends Component {
  @service currentUser;
  @service chatHistory;
  @service site;

  get backLink() {
    const prevPage = this.chatHistory.previousRoute?.name;
    let route, title, models;

    if (prevPage === "chat.channel.threads") {
      route = "chat.channel.threads";
      title = I18n.t("chat.return_to_threads_list");
      models = this.channel?.routeModels;
    } else if (prevPage === "chat.channel.index" && !this.site.mobileView) {
      route = "chat.channel.threads";
      title = I18n.t("chat.return_to_threads_list");
      models = this.channel?.routeModels;
    } else if (!this.currentUser.isInDoNotDisturb() && this.unreadCount > 0) {
      route = "chat.channel.threads";
      title = I18n.t("chat.return_to_threads_list");
      models = this.channel?.routeModels;
    } else if (prevPage === "chat.threads") {
      route = "chat.threads";
      title = I18n.t("chat.my_threads.title");
      models = [];
    } else {
      route = "chat.channel.index";
      title = I18n.t("chat.return_to_channel");
      models = this.channel?.routeModels;
    }

    return { route, models, title };
  }

  get channel() {
    return this.args.thread?.channel;
  }

  get headerTitle() {
    return this.args.thread?.title ?? I18n.t("chat.thread.label");
  }

  get unreadCount() {
    return this.channel?.threadsManager?.unreadThreadCount;
  }

  <template>
    <Navbar as |navbar|>
      {{#if @thread}}
        <navbar.BackButton
          @route={{this.backLink.route}}
          @routeModels={{this.backLink.models}}
          @title={{this.backLink.title}}
        >
          <ChatThreadHeaderUnreadIndicator @channel={{this.channel}} />
          {{icon "chevron-left"}}
        </navbar.BackButton>
      {{/if}}

      <navbar.Title @title={{replaceEmoji this.headerTitle}} />
      <navbar.Actions as |action|>
        <action.ThreadTrackingDropdown @thread={{@thread}} />
        <action.ThreadSettingsButton @thread={{@thread}} />
        <action.CloseThreadButton @thread={{@thread}} />
      </navbar.Actions>
    </Navbar>
  </template>
}
