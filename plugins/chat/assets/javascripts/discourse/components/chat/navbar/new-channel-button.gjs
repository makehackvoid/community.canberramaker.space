import Component from "@glimmer/component";
import { action } from "@ember/object";
import { inject as service } from "@ember/service";
import DButton from "discourse/components/d-button";
import concatClass from "discourse/helpers/concat-class";
import CreateChannelModal from "discourse/plugins/chat/discourse/components/chat/modal/create-channel";

export default class ChatNavbarNewChannelButton extends Component {
  @service chatStateManager;
  @service currentUser;
  @service modal;
  @service site;

  @action
  createChannel() {
    this.modal.show(CreateChannelModal);
  }

  <template>
    {{#if this.currentUser.staff}}
      <DButton
        @action={{this.createChannel}}
        @icon="plus"
        @label={{if this.site.desktopView "chat.create_channel.title"}}
        class={{concatClass
          "c-navbar__new-channel-button"
          (if this.site.mobileView "btn-flat")
        }}
      />
    {{/if}}
  </template>
}
