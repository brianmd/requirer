require 'spec_helper'

# add directory to load_path where test files to load exist
$LOAD_PATH.unshift 'spec/dirs_to_require'

describe Requirer do
  before { $bucket = [] }

  describe 'require a single directory' do
    it 'file is loaded' do
      require_dir 'dir_depth_2'
      expect($bucket).to eq(['depth_zero'])
    end
  end

  describe 'require directory with depth 1' do
    it 'file is loaded' do
      require_dir_tree 'dir_depth_1'
      expect($bucket).to eq(['depth_one'])
    end

    it 'file is loaded only once even though required twice' do
      require_dir_tree 'dir_depth_1_only'
      require_dir_tree 'dir_depth_1_only'
      expect($bucket).to eq(['depth_one'])
    end
  end

  describe 'files in each level of directory tree is loaded' do
    it 'is breadth first' do
      require_dir_tree 'dir_depth_3'
      expect($bucket).to eq(['depth_one(3)', 'depth_two', 'depth_two,b', 'depth_three'])
    end
  end

  describe 'require non-existent directory' do
    it 'raises an error' do
      expect{ require_dir_tree('nobody-is-home') }.to raise_error(DirUtilsException)
    end
  end

  describe 'where_is works' do
    it 'finds file_to_find.rb' do
      expect(find_file_with('file_to_find.rb').split('/').last).to eq('file_to_find.rb')
      expect(where_is?('file_to_find.rb').split('/').last).to eq('file_to_find.rb')
    end

    it 'finds file with directory as part of the requested path' do
      expect(where_is?('dir_depth_1/depth1.rb').split('/').last).to eq('depth1.rb')
      expect(where_is?('dir_depth_1/depth1.rb').split('/')[-2]).to eq('dir_depth_1')
    end

    it 'finds file with directory as part of the requested path' do
      filename = File.expand_path("../dirs_to_require/dir_depth_1/depth1.rb", __FILE__)
      found_filename = where_is?(filename)
      expect(found_filename[0]).to eq('/')
      expect(found_filename.split('/').last).to eq('depth1.rb')
      expect(found_filename.split('/')[-2]).to eq('dir_depth_1')
    end

    it 'raises error on bad  path' do
      expect{ where_is?('asdf') }.to raise_error(DirUtilsException)
    end

    it 'raises error on bad absolute path' do
      expect{ where_is?('/asdf') }.to raise_error(DirUtilsException)
    end
  end
end
