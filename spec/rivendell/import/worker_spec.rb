require 'spec_helper'

describe Rivendell::Import::Worker do

  let(:import) { Rivendell::Import::Base.new }
  subject { Rivendell::Import::Worker.new import }

  describe "initialization" do

    it "should use the given Import" do
      Rivendell::Import::Worker.new(import).import.should == import
    end
    
  end

  it "should run Import tasks in a separated Thread" do
    import.tasks << mock(:run => true)
    subject.start
    sleep 0.5
    import.tasks.should_not be_pending
  end

end
