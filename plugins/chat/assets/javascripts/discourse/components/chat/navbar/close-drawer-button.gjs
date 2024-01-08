import Component from "@glimmer/component";
import { action } from "@ember/object";
import { inject as service } from "@ember/service";
import DButton from "discourse/components/d-button";

export default class ChatNavbarCloseDrawerButton extends Component {
  @service chat;
  @service chatStateManager;

  @action
  closeDrawer() {
    this.chatStateManager.didCloseDrawer();
    this.chat.activeChannel = null;
  }

  <template>
    <DButton
      @icon="times"
      @action={{this.closeDrawer}}
      @title="chat.close"
      class="btn-flat no-text c-navbar__close-drawer-button"
    />
  </template>
}
