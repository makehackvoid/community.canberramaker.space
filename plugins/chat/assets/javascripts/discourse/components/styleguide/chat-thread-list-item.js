import Component from "@glimmer/component";
import { inject as service } from "@ember/service";
import fabricators from "discourse/plugins/chat/discourse/lib/fabricators";

export default class ChatStyleguideChatThreadListItem extends Component {
  @service currentUser;

  thread = fabricators.thread();
}
