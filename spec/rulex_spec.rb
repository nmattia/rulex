require 'spec_helper'

def pandoc?
  begin
    `pandoc -v`
  rescue Errno::ENOENT
    return false
  end
  return true
end

describe Rulex do
  it 'has a version number' do
    expect(Rulex::VERSION).not_to be nil
  end
end
