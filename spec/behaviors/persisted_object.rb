shared_examples_for 'a persisted object' do
  let :clazz do
    subject.class
  end
  it 'should have a storage name' do
    clazz.storage_name.should =~ /^\w+$/
  end
end