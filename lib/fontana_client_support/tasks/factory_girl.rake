require 'fontana_client_support'
include Fontana::ServerRake

namespace_with_fontana :factory_girl, :"app_seed:generate" do

  # desc "generate spec/support/models files"
  fontana_task :spec_support_models, env: {
    "SPEC_SUPPORT_MODELS_DIR" => File.expand_path("spec/support/models", FontanaClientSupport.root_dir)
  }

  # desc "generate spec/factories files"
  fontana_task :spec_factories, env: {
    "SPEC_FACTORIES_DIR" => File.expand_path("spec/factories", FontanaClientSupport.root_dir)
  }
end

desc "generate spec/support/models files and spec/factories files"
task :factory_girl => [:"factory_girl:spec_support_models", :"factory_girl:spec_factories"]
