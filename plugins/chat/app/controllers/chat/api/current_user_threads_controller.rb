# frozen_string_literal: true

class Chat::Api::CurrentUserThreadsController < Chat::ApiController
  def index
    with_service(::Chat::LookupUserThreads) do
      on_success do
        render_serialized(
          ::Chat::ThreadsView.new(
            user: guardian.user,
            threads: result.threads,
            channel: result.channel,
            tracking: result.tracking,
            memberships: result.memberships,
            load_more_url: result.load_more_url,
            threads_participants: result.participants,
          ),
          ::Chat::ThreadListSerializer,
          root: false,
        )
      end
      on_model_not_found(:threads) { render json: success_json.merge(threads: []) }
    end
  end
end
