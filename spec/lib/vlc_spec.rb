describe VLC do
  its(:binary) { should be_a(String)}
  its(:version) { should =~ /^[\d\.]+$/ }
  it 'should play a song, block the thread and return number of seconds played' do
    subject.play('media/gentle_marimba.mp3').should >= 103
  end
end