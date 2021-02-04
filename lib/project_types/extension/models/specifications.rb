module Extension
  module Models
    class Specifications
      HANDLER_IMPLEMENTAION_DIRECTORY = File.expand_path('lib/project_types/extension/models/types', ShopifyCli::ROOT)

      def initialize(&fetch_specifications)
        @handlers = build_handlers(&fetch_specifications)
      end

      def [](identifier)
        handlers[identifier]
      end

      def valid?(identifier)
        handlers.key?(identifier)
      end

      def each(&block)
        handlers.values.each(&block)
      end

      def register(type)
        handlers[type.identifier] = type
      end

      def unregister(type)
        handlers.delete(type.identifier)
      end

      protected

      attr_reader :handlers

      private

      def build_handlers(&fetch_specifications)
        ShopifyCli::Result
          .wrap(&fetch_specifications)
          .call
          .then(&method(:require_handler_implementations)) 
          .then(&method(:instantiate_specification_handlers))
          .unwrap { |err| raise err }
      end

      def require_handler_implementations(specifications)
        specifications.each { |s| require(File.join(HANDLER_IMPLEMENTAION_DIRECTORY, "#{s.identifier}.rb"))}
      end

      def instantiate_specification_handlers(specifications)
        specifications.each_with_object({}) do |specification, handlers|
          handler = Extension::Models::Types.const_get(specification.handler_class_name).new
          handlers[handler.identifier] = handler
        end
      end
    end
  end
end
