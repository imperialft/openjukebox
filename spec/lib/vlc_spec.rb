describe VLC do
  context 'Class' do
    subject { VLC }
    its(:binary) { should be_a(String) }
  end
  its(:version) { should =~ /^[\d\.]+$/ }
end