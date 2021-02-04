# frozen_string_literal: true

module Extension
  module ExtensionTestHelpers
    module TestExtensionSetup
      def setup
        ShopifyCli::ProjectType.load_type(:extension)

        @test_extension_type = ExtensionTestHelpers::TestExtension.new
        Extension.specifications.register(@test_extension_type)
        super
      end

      def teardown
        super
        Extension.specifications.unregister(@test_extension_type)
      end
    end
  end
end
