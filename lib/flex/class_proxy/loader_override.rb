module Flex
  module ClassProxy
    module LoaderOverride

      def render(name, *vars)
        templates[name].render(*vars).get_docs
      end

    end
  end
end
