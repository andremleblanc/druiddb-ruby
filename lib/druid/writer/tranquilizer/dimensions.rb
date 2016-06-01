module Druid
  module Writer
    module Tranquilizer
      class Dimensions
        class << self
          java_import com.metamx.tranquility.druid.DruidDimensions

          def build(dimensions)
            dimensions_list = ImmutableList.of(*dimensions.keys)
            DruidDimensions.specific(dimensions_list)
          end
        end
      end
    end
  end
end
