describe VLC do
  its(:binary) { should be_a(String)}
  its(:version) { should =~ /^[\d\.]+$/ }
end