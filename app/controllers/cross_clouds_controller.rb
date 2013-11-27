class CrossCloudsController < ApplicationController
  respond_to :html, :js
  include CrossCloudsHelper
  add_breadcrumb "Dashboard", :dashboards_path
  def index
    add_breadcrumb "Cross Clouds", cross_clouds_path
    cross_cloud_options = { :email => current_user.email, :api_key => current_user.api_token }
    @cross_clouds = ListPredefClouds.perform(cross_cloud_options)
    if @cross_clouds.class == Megam::Error
      redirect_to dashboards_path, :gflash => { :warning => { :value => "Oops! sorry, #{@cross_clouds.some_msg[:msg]}", :sticky => false, :nodom_wrap => true } }
    end
    puts "============================> @CROSS CLOUD INDEX <==================================="
    puts @cross_clouds.inspect
  end

  def new
    add_breadcrumb "Cross Clouds", cross_clouds_path
    add_breadcrumb "New Cross Cloud", new_cross_cloud_path
    logger.debug "GOOGLE oauth token ============> "
    puts request.env['omniauth.auth']
  end

  def create
    logger.debug "CROSS CLOUD CREATE PARAMS ============> "
    logger.debug "#{params}"

    #require 'fileutils'
    #tmp = params[:aws_file].tempfile
    #file = File.join("public", params[:aws_file].original_filename)
    #FileUtils.cp tmp.path, file
    # YOUR PARSING JOB
    #FileUtils.rm file
    #uploaded_io = params[:aws_file]
    #File.open(Rails.root.join('public', 'uploads', uploaded_io), 'w') do |file|
    #file.write(uploaded_io.read)
    #end

    vault_loc = get_Vault_server+current_user.email+"/"+params[:name]
    options = { :email => current_user.email, :api_key => current_user.api_token, :name => params[:name], :spec => { :type_name => get_provider_value(params[:provider]), :groups => params[:group], :image => params[:image], :flavor => params[:flavour] }, :access => { :ssh_key => params[:ssh_key], :identity_file => File.basename(params[:aws_private_key]), :ssh_user => params[:ssh_user], :vault_location => vault_loc }  }
    res_body = CreatePredefClouds.perform(options)
    upload_option = {:email => current_user.email, :name => params[:name], :aws_private_key => params[:aws_private_key], :aws_access_key => params[:aws_access_key], :aws_secret_key => params[:aws_secret_key], :type => cc_type(params[:provider]), :id_rsa_public_key => params[:id_rsa_public_key]}
    puts "=============================================="
    puts upload_option
    #aws_upload = S3Upload.perform(params[:aws_private_key], current_user.email+"/"+params[:name])
    aws_upload = S3Upload.perform(upload_option)
    redirect_to cross_clouds_path, :gflash => { :warning => { :value => "CROSS  CLOUD CREATION DONE ", :sticky => false, :nodom_wrap => true } }
  end

  def show
    cross_cloud_options = { :email => current_user.email, :api_key => current_user.api_token }
    @cross_clouds = ListPredefClouds.perform(cross_cloud_options)
    @cross_cloud = @cross_clouds.lookup(params[:id])
  end
end