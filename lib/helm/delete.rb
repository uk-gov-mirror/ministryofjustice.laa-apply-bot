module Helm
  class Delete
    def self.call(release)
      @release = release
      remove_release if dry_run?
    end

    class <<self
      private

      def remove_release
        result = `helm delete #{@release}`.chomp
        result.eql?("release \"#{@release}\" uninstalled")
      end

      def dry_run?
        result = `helm delete #{@release} --dry-run`.chomp
        result.eql?("release \"#{@release}\" uninstalled")
      end
    end
  end
end
