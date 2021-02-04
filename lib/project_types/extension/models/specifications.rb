module Extension
  module Models
    class Specifications
      def initialize
        @repository = load_all_types
      end

      def [](identifier)
        repository[identifier]
      end

      def valid?(identifier)
        repository.key?(identifier)
      end

      def each(&block)
        repository.values.each(&block)
      end

      def register(type)
        repository[type.identifier] = type
      end

      def unregister(type)
        repository.delete(type.identifier)
      end

      protected

      attr_reader :repository

      private

      def load_all_types
        search_pattern = %w[lib project_types extension models types *.rb]
        Dir.glob(File.join(ShopifyCli::ROOT, search_pattern)).each_with_object({}) do |path, repository|
          require(path)

          build_type(infer_type_name_from_path(path)).tap do |type|
            repository[type.identifier] = type
          end
        end
      end

      def infer_type_name_from_path(path)
        File.basename(path, '.rb').split('_').map(&:capitalize).join
      end

      def build_type(class_name)
        Extension::Models::Types.const_get(class_name).new
      end
    end
  end
end
