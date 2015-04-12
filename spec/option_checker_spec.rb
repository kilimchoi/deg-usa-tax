require 'spec_helper'

describe DegUsaTax::OptionChecker do
  before do
    String.new.gsub('','')
    klass = Class.new
    klass.class_eval do
      include DegUsaTax::OptionChecker

      def foo(opts = {})
        check_opts opts, [:bar]
      end
    end
    @s = klass.new
  end

  subject { @s }

  it 'accepts it if no options are passed' do
    expect { subject.foo }.to_not raise_error
  end

  it 'accepts options on the list' do
    expect { subject.foo(bar: 10) }.to_not raise_error
  end

  it 'raises ArgumentError is unrecognized options are passed' do
    expect { subject.foo(junk: 10) }.to raise_error \
      ArgumentError, "Invalid keys: junk"
  end
end
