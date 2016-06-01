module Druid
  module Writer
    module Tranquilizer
      java_import com.metamx.tranquility.druid.DruidBeams

      class DruidBeams
        # Ensures the correct override is used.
        java_alias :timestamper_builder, :builder, [com.metamx.tranquility.typeclass.Timestamper.java_class]
      end
    end
  end
end
