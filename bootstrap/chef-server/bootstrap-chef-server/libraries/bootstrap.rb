module BootStrap

  # Populate chef-server.configuration attributes
  #
  def load_attributes_from_env(bootstrap_type)
    bootstrap_type = bootstrap_type.to_sym

    # Hash of node_type => [ services disabled ]
    svc_notused = {
      :erchef => %w{chef-expander chef-solr rabbitmq},
      :solr  => %w{erchef nginx lb chef-server-webui postgresql bookshelf bootstrap}
    }

    # Set disabling options depending on the node type
    svc_notused[bootstrap_type].each {|v| node.normal['chef-server']['configuration'][v]['enable'] = false }

    # Build configuration options using the environment
    conf_units = %w{
      rabbitmq
      chef-solr
      bookshelf
      erchef
      chef-server-webui
      lb
    }

    # Set attributes, lookfor env variables like RABBITMQ_*, CHEF_SOLR
    conf_units.each do |u|
      uprefix = u.sub(/-/, '_').upcase
      ENV.select {|k, v| k.start_with?(uprefix) }.each do |opt, val|
        if not val.empty?
          node.normal['chef-server']['configuration'][u][opt.sub(/^#{uprefix}_/,'').downcase] = val
        end
      end
    end
  end

end