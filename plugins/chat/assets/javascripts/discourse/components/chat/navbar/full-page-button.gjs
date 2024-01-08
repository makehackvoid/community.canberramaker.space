import Component from "@glimmer/component";
import { action } from "@ember/object";
import { next } from "@ember/runloop";
import { inject as service } from "@ember/service";
import DButton from "discourse/components/d-button";
import DiscourseURL from "discourse/lib/url";

export default class ChatNavbarFullPageButton extends Component {
  @service chat;
  @service chatStateManager;

  @action
  async openInFullPage() {
    this.chatStateManager.storeAppURL();
    this.chatStateManager.prefersFullPage();
    this.chat.activeChannel = null;

    await new Promise((resolve) => next(resolve));

    DiscourseURL.routeTo(this.chatStateManager.lastKnownChatURL);
  }

  <template>
    {{#if this.chatStateManager.isDrawerExpanded}}
      <DButton
        @icon="discourse-expand"
        class="btn-flat no-text c-navbar__full-page-button"
        @title="chat.open_full_page"
        @action={{this.openInFullPage}}
      />
    {{/if}}
  </template>
}
