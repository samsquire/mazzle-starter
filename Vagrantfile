BOX_IMAGE = "ubuntu/disco64"
NODE_COUNT = 4

Vagrant.configure("2") do |config|
  config.vm.define "master" do |subconfig|
    subconfig.vm.box = BOX_IMAGE
  end
  config.vm.network "private_network", type: "dhcp"  
  (1..NODE_COUNT).each do |i|
    config.vm.define "node#{i}" do |subconfig|
      subconfig.vm.box = BOX_IMAGE
    end
  end

  config.vm.provision :hosts do |provisioner|
  end
end
