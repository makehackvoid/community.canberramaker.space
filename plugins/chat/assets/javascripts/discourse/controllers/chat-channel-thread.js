import { tracked } from "@glimmer/tracking";
import Controller from "@ember/controller";
import { inject as service } from "@ember/service";

export default class ChatChannelThreadController extends Controller {
  @service chat;

  @tracked targetMessageId = null;
}
