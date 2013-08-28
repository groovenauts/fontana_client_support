require 'fontana_client_support'
include Fontana::ServerRake

namespace_with_fontana :app_seed, :app_seed do

  desc "show collection types"
  fontana_task :show_collection_types

end
