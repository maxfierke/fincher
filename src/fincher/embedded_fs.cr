module Fincher
  class EmbeddedFs
    extend BakedFileSystem

    bake_folder "../../data"
  end
end
