require 'jwt'
require 'fluent/plugin/filter'

module Fluent::Plugin
    class JwtToken < Filter
        Fluent::Plugin.register_filter('jwt', self)

        helpers :record_accessor

        desc 'JWT signing algorithm'
        config_param :algorithm, :string, default: 'RS256'
        desc 'The hash field stores parsed value'
        config_param :hash_value_field, :string, default: nil
        desc 'JWT method which could either be encryption or decryption'
        config_param :method, :string, default: 'decrypt'
        desc 'The given key in the record that was used for encryption or decryption'
        config_param :key_name, :string

        DECRYPT = 'decrypt'

        def configure(conf)
            super

            @accessor = record_accessor_create(@key_name)
        end

        def filter(tag, time, record)
            case @method
            when JwtToken::DECRYPT
                value = @accessor.call(record)

                if value.nil?
                    router.emit_error_event(tag, time, record, ArgumentError.new("#{@key_name} does not exist"))
                end

                if ! value.empty?
                    record = record.merge(@hash_value_field ? {@hash_value_field => decrypt(value)} : {})
                end

                record
            else
                router.emit_error_event(tag, time, record, ArgumentError.new("Invalid method option [#{method}]"))
            end
        end

        def decrypt(token)
            begin
                token = JWT.decode token, nil, false, { algorithm: @algorithm }
                log.debug token
                token
            rescue => e
                log.error 'Failed to decrypt the token', error: e.to_s, token: token
                log.debug_backtrace(e.backtrace)
            end
        end
    end
end
