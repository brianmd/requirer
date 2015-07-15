warn 'in requirer_spec'
require 'spec_helper'

$LOAD_PATH.unshift 'spec/dirs_to_require'

describe Requirer do
  before { $bucket = [] }

  describe 'require directory with depth 1' do
    it 'is loaded' do
      dir_tree 'dir_depth_1'
      expect($bucket).to eq(['depth_one'])
    end

    it 'is loaded only once even though required twice' do
      dir_tree 'dir_depth_1_only'
      dir_tree 'dir_depth_1_only'
      expect($bucket).to eq(['depth_one'])
    end
  end

  describe 'require directory with depth 1' do
    it 'is breadth first' do
      dir_tree 'dir_depth_3'
      expect($bucket).to eq(['depth_one(2)', 'depth_two', 'depth_three'])
    end
  end

  describe 'require non-existent directory' do
    it 'expect error' do
      expect{ dir_tree('nobody-is-home') }.to raise_error(DirUtilsException)
    end
  end
end