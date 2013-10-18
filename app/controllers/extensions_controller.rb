class ExtensionsController < ApplicationController
  before_filter :assign_extension, :only => [:show, :edit, :update, :destroy]
  before_filter :require_correct_permissions, :only => [:edit, :update, :destroy]

  ORDER_BY = {
    'name' => 'name',
    'updated' => 'updated_at DESC'
  }
  
  # GET /extensions
  # GET /extensions.atom
  def index
    @order = params[:order]
    @order ||= 'name'
    
    respond_to do |format|
      format.html { @extensions = Extension.paginate :page => params[:page], :order => ORDER_BY[@order], :include => :author }
      format.xml  { @extensions = Extension.find(:all, :order=>"updated_at DESC", :include => :author); render :xml => @extensions }
      format.atom { @extensions = Extension.find(:all, :order=>"updated_at DESC", :include => :author) }
    end
  end
  
  def all
    @extensions = Extension.paginate :page => params[:page], :order => 'name', :per_page => Extension.count, :include => :author
    render :action => :index
  end
  
  # GET /extensions/1
  # GET /extensions/1.xml
  def show
    respond_to do |format|
      format.html
      format.xml { render :xml => @extension }
    end
  end
  
  # GET /extensions/new
  def new
    @extension = Extension.new
  end
  
  # GET /extensions/1/edit
  def edit
  end
  
  # POST /extensions
  # POST /extensions.xml
  def create
    @extension = Extension.new(extension_params)
    @extension.author = current_user
    respond_to do |format|
      if @extension.save
        format.html { flash[:notice] = 'Created successfully!'; redirect_to extension_url(@extension) }
        format.js
        format.xml  { head :created, :location => extension_url(@extension) }
      else
        format.html { flash[:error] = 'There was a problem!'; render :action => "new", :status => 422 }
        format.js
        format.xml  { render :xml => @extension.errors.to_xml, :status => :unprocessible_entity }
      end
    end
  end
  
  # PUT /extensions/1
  # PUT /extensions/1.xml
  def update
    respond_to do |format|
      if @extension.update_attributes(extension_params)
        format.html { flash[:notice] = 'Updated successfully!'; redirect_to extension_url(@extension) }
        format.js
        format.xml  { head :ok }
      else
        format.html { flash[:error] = 'There was a problem saving!'; render :action => "edit", :status => 422 }
        format.js
        format.xml  { render :xml => @extension.errors.to_xml, :status => :unprocessible_entity }
      end
    end
  end

  # DELETE /extensions/1
  # DELETE /extensions/1.xml
  def destroy
    if @extension.destroy
      respond_to do |format|
        format.html { flash[:notice] = "Record deleted!"; redirect_to extensions_url }
        format.js
        format.xml  { head :ok }
      end
    else
      respond_to do |format|
        format.html { flash[:error] = "There was a problem deleting!"; redirect_to :back, :status => :failure }
        format.js
        format.xml  { head :failure }
      end
    end
  end
  
  protected
    
    def assign_extension
      @extension = Extension.find(params[:id])
    end

    def extension_params
      params.require(:extension).permit(:name, :current_version, :homepage_url, :supports_sass_version, :repository_url, :repository_type, :download_url, :download_type, :description, :installation_instructions, :screenshot)
    end
    
    def require_correct_permissions
      unless can_edit?(@extension)
        respond_to do |format|
          format.html do
            flash[:error] = "You can only edit your own extensions."
            redirect_to extensions_url
          end
          format.xml { head :forbidden }
        end
        return false
      end
    end
  
end
