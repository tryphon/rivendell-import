require 'spec_helper'

describe Rivendell::Import::Base do

  describe "#prepare_task" do

    let(:task) { mock }
    
    it "should prepare task with to_prepare block" do
      subject.to_prepare = Proc.new {}
      task.should_receive :prepare
      subject.prepare_task task
    end

  end

  describe "#create_task" do

    let(:file) { Rivendell::Import::File.new "dummy.wav" }
    let(:task) { Rivendell::Import::Task.new }

    before(:each) do
      Rivendell::Import::Task.stub :new => task
    end
    
    it "should create a task with given file" do
      Rivendell::Import::Task.should_receive(:new).with(file)
      subject.create_task file
    end

    it "should prepare task" do
      subject.should_receive(:prepare_task).and_return(task)
      subject.create_task file
    end

    it "should add task" do
      subject.create_task file
      subject.tasks.pop.should == task
    end

  end

  describe "#file" do

    let(:file) { Rivendell::Import::File.new("dummy.wav") }
    
    it "should create a File with given path and base_directory" do
      Rivendell::Import::File.should_receive(:new).with("path", :base_directory => "base_directory")
      subject.file "path", "base_directory"
    end

    it "should create a File with given path and base_directory" do
      Rivendell::Import::File.stub :new=> file
      subject.should_receive(:create_task).with(file)
      subject.file "path", "base_directory"
    end

  end

  describe "#directory" do
    
    it "should look for files in given directory" do
      Dir.mktmpdir do |directory| 
        FileUtils.mkdir "#{directory}/subdirectory"
        
        file = "#{directory}/subdirectory/dummy.wav"
        FileUtils.touch file

        subject.should_receive(:file).with(file, directory)
        subject.directory directory
      end
    end

  end
  
  describe "#process" do
    
    it "should use file method when path isn't a directory" do
      File.stub :directory? => false
      subject.should_receive(:file).with("dummy")
      subject.process("dummy")
    end

    it "should use directory method when path is a directory" do
      File.stub :directory? => true
      subject.should_receive(:directory).with("dummy")
      subject.process("dummy")
    end

  end

  describe "#listen" do

    before(:each) do
      Listen.stub :to => true
    end

    let(:directory) { "directory" }
    let(:worker) { mock }

    before(:each) do
      worker.stub :start => worker
      Rivendell::Import::Worker.stub :new => worker
    end
    
    it "should create a Worker" do
      Rivendell::Import::Worker.should_receive(:new).with(subject).and_return(worker)
      subject.listen directory
      subject.workers.should == [ worker ]
    end

    it "should start Worker" do
      worker.should_receive(:start).and_return(worker)
      subject.listen directory
    end

    it "should not create Worker with dry_run option" do
      subject.listen directory, :dry_run => true
      subject.workers.should be_empty
    end

    it "should invoke Listen.to with given directory" do
      Listen.should_receive(:to).with(directory)
      subject.listen directory
    end

    it "should invoke file with added files" do
      Listen.stub(:to).and_yield(nil,%w{file},nil)
      subject.should_receive(:file).with("file", directory)
      subject.listen directory
    end

  end

end
