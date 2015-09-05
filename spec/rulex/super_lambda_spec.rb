require 'spec_helper'

describe Rulex::SuperLambda do

  it 'is callable' do
    sl = Rulex::SuperLambda.new {|s| puts s}
    expect(sl).to respond_to(:call)
  end

  it 'forwards call to block' do
    sl = Rulex::SuperLambda.new {|s| 2*s}
    expect(sl.call(4)).to eq(8)
  end

  it 'forwards call to proc' do
    sl = Rulex::SuperLambda.new proc {|s| 2*s}
    expect(sl.call(4)).to eq(8)
  end

  it 'forwards call to lambda' do
    sl = Rulex::SuperLambda.new ->(s){ 2*s}
    expect(sl.call(4)).to eq(8)
  end

  it 'gives priority to lambdas with the right # of args' do
    sl = Rulex::SuperLambda.new(->(x){ 2*x }, ->(x,y){2*x*y})
    expect(sl.call(4,8)).to eq(64)
  end

  it 'appends a callable object' do
    sl = Rulex::SuperLambda.new(->(x){ 2*x })
    sl << ->(x,y){ "it's me" }

    expect(sl.call(4,8)).to eq("it's me")
  end


  it 'chooses the firstly added callable' do
    sl = Rulex::SuperLambda.new
    sl << ->(){ "it's me"}
    sl << ->(){ "it's not me"}

    expect(sl.call).to eq("it's me")
  end

end
