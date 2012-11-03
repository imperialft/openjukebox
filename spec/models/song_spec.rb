describe Song do
  it_should_behave_like 'a persisted object'
  describe '.root' do
    it 'should exist' do
      File.exists?(Song.root).should be_true
    end
    it 'should be a directory' do
      File.directory?(Song.root).should be_true
    end
  end
  describe '#play' do
    it 'should play a song'
  end
  describe '#fullpath' do
    before { subject.path = 'test.mp3' }
    it 'should be a full path' do
      subject.fullpath.should == File.expand_path('media/test.mp3')
    end
  end
end