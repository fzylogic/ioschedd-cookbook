#
# Cookbook Name:: ioschedd
# Recipe:: default
#
# Copyright 2012, Jeremy Hanmer
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

default_scheduler = node["ioschedd"]["scheduler"] 
deviceblock = ""

defaults = "default: " + default_scheduler

def gen_config (dev, scheduler, devtype, blacklist)
  devtype = 'devpath' if ( devtype.nil? )
  Chef::Log.info("Setting up ioschedd device " + dev)
  snippet = devtype + "=" + dev + "\n"
  snippet.concat("\tscheduler: " + scheduler + "\n")
  snippet.concat("\tblacklist: " + blacklist + "\n") if blacklist
  snippet.concat("\n")
  return snippet
end

if (!node["ioschedd"]["devices"].nil?) then
  node["ioschedd"]["devices"].each do |dev|
    scheduler = dev["scheduler"]
    if ( scheduler.nil? )
      scheduler = default_scheduler
    end
    deviceblock.concat(gen_config(dev, scheduler, dev["devtype"], dev["blacklist"]))
  end
end

if (!node['ceph']['osd_devices'].nil?) then
  node['ceph']['osd_devices'].each do |dev|
    scheduler = dev["scheduler"]
    if ( scheduler.nil? )
      scheduler = default_scheduler
    end
    deviceblock.concat(gen_config(dev['data_dev'], scheduler, dev["devtype"], dev["blacklist"]))
  end
end

template "/etc/ioschedd.conf" do
  source "ioschedd.conf.erb"
  owner "root"
  group "root"
  mode "0644"
  variables(
    :defaults => defaults,
    :deviceblock => deviceblock
  )
end

