flavour_version = "#{node['orientdb']['flavour']}-#{node['orientdb']['version']}"
filename = "#{flavour_version}.tar.gz"
resource_url = "#{node['orientdb']['base_tarball_url']}-#{filename}"

version_file_check = "#{node['orientdb']['installation_directory']}/lib/orientdb-core-#{node['orientdb']['version']}.jar"

case node['platform_family']
when 'debian'
  require 'tmpdir'

  # Delete folder contents that would be affected during a version update (ie new lib and plugin versions) as well as temp directory.
  # - Only if exists (implicit with directory resource)
  # - Only if the version being installed differs from what is already installed.
  [ "#{node['orientdb']['installation_directory']}/lib", "#{node['orientdb']['installation_directory']}/plugins", "#{node['orientdb']['installation_directory']}/databases/temp" ].each do |path|
    directory path do
      action :delete
      recursive true
      not_if { ::File.exist?(version_file_check) }
    end
  end
  # Downlad tar file into Chef cache via tar_extract & then extract to destination, keeping new files if there, setting correct group, user, & mode.
  # - Only if the version isn't already extracted (via "creates" attribute with tar cookbook) [checks to see if already on sys before download]

  tar_extract resource_url do
    target_dir node['orientdb']['installation_directory']
    tar_flags ['--strip-components 1', '--keep-newer-files' ]
    group node['orientdb']['user']['id']
    user node['orientdb']['user']['id']
    mode '0755'
    download_dir Dir.tmpdir
    creates version_file_check
  end

when 'rhel'
  log "Installing into: #{node['orientdb']['installation_directory']} Version:#{node['orientdb']['version']}"
  download_file = "https://s3.us-east-2.amazonaws.com/orientdb3/releases/#{node['orientdb']['version']}/orientdb-#{node['orientdb']['version']}.tar.gz"
  poise_archive download_file.to_s do
    destination (node['orientdb']['installation_directory']).to_s
  end
end
