# frozen_string_literal: true

module Runcom
  # A generic key-value pair (KVP).
  Pair = Struct.new :key, :value do
    def to_env
      Hash[*values]
    end
  end
end