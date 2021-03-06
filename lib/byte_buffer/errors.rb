class ByteBuffer
  module Errors
    class ByteBufferError < StandardError
      @@used_codes = []

      def self.status_code(code = nil)
        if code
          raise "Status code already in use: #{code}"  if @@used_codes.include?(code)
          @@used_codes << code
        end

        define_method(:status_code) { code }
      end

      def self.error_key(key=nil, namespace=nil)
        define_method(:error_key) { key }
        error_namespace(namespace) if namespace
      end

      def self.error_namespace(namespace)
        define_method(:error_namespace) { namespace }
      end

      def initialize(message=nil, *args)
        message = { :_key => message } if message && !message.is_a?(Hash)
        message = { :_key => error_key, :_namespace => error_namespace }.merge(message || {})
        message = translate_error(message)

        super
      end

      def error_namespace; "byte_buffer.errors"; end
      def error_key; nil; end

      protected

      def translate_error(opts)
        return nil if !opts[:_key]
        I18n.t("#{opts[:_namespace]}.#{opts[:_key]}", opts)
      end
    end

    class BufferUnderflow < ByteBufferError
      status_code(5)
      error_key(:buffer_underflow)
    end

    class CannotWriteInReadMode < ByteBufferError
      status_code(10)
      error_key(:cannot_write_in_read_mode)
    end

    class CannotReadInWriteMode < ByteBufferError
      status_code(11)
      error_key(:cannot_read_in_write_mode)
    end

    class ExpectedInteger < ByteBufferError
      status_code(20)
      error_key(:expected_integer)
    end

    class ExpectedIntegerSeries < ByteBufferError
      status_code(21)
      error_key(:expected_integer_series)
    end

    class TypeAlreadyDefined < ByteBufferError
      status_code(30)
      error_key(:data_type_already_defined)
    end

    class UnsupportedData < ByteBufferError
      status_code(40)
      error_key(:unsupported_data)
    end

  end
end
