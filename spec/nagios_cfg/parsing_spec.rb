#
# Parsing test for nagios.cfg file. Make sure that all allowed entries
# are parseable and return correct data.
#
require_relative '../spec_helper'

# ==================================================================
# Shared examples
#
shared_examples_for :parseable do |file, sym, klass|
  before do
    @cfg = Nagios::Config.new file 
    klass = klass || Numeric
  end

  it "parse file '#{File.basename file}'" do 
    lambda { @cfg.parse }.should_not raise_error
  end


  context :on_parse do 
    before { @cfg.parse }
    
    it "define method :#{sym}" do
      expect(@cfg).to respond_to sym
    end
    
    it "is #{klass || Numeric} class" do
      @cfg.send(sym).should be_a_kind_of klass
    end
  end                           # :parse
end                             # :parseable

shared_examples_for :bad_format do |file|
  it "#{File.basename file} parse" do
    cfg = Nagios::Config.new file
    lambda { cfg.parse }.should raise_error
  end
end                             # :bad_format

shared_examples_for :define_method_runtime do |file, sym|
  before { @cfg = Nagios::Config.new file }

  it "no method :#{sym} before parse" do
    expect(@cfg).not_to respond_to sym
  end
end

shared_examples_for :cfg_file_or_dir do |file, sym|
  before { (@cfg = Nagios::Config.new(file)).parse}
  it ("contains data") { expect(@cfg.cfg_file).not_to be_empty }
end
# ==================================================================

data_top = File.join($package_top,'test','data','nagios_cfg')

describe "Configuration" do 
  describe :external_commands do
    data = File.join data_top, 'external_commands' # Directory with
                                                   # test config files

    it_should_behave_like :define_method_runtime,  File.join(data, "nagios.cfg"), :command_check_interval

    it_should_behave_like :parseable,  File.join(data, "nagios.cfg"), :command_check_interval
    it_should_behave_like :parseable,  File.join(data, "command_check_interval_minus1"), :command_check_interval
    it_should_behave_like :parseable,  File.join(data, "command_check_interval_5"), :command_check_interval
    it_should_behave_like :parseable,  File.join(data, "command_check_interval_300s"), :command_check_interval, String

    it_should_behave_like :bad_format, File.join(data, "command_check_interval_bad")
  end                           # :external_commands

  describe :cfg_file do
    data = data_top             # Directory with test config files
    it_should_behave_like :parseable,  File.join(data, "nagios.cfg"), :cfg_file, Array
    it_should_behave_like :cfg_file_or_dir, File.join(data, "nagios.cfg"), :cfg_file
  end                                     # :cfg_file
  
  describe :cfg_dir do
    data = data_top             # Directory with test config files
    it_should_behave_like :parseable,  File.join(data, "nagios.cfg"), :cfg_dir, Array
    it_should_behave_like :cfg_file_or_dir, File.join(data, "nagios.cfg"), :cfg_dir
  end                                     # :cfg_dir
end
