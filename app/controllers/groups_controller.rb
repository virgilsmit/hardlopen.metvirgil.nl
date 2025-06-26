class GroupsController < ApplicationController
  before_action :set_group, only: %i[ show edit update destroy ]

  # GET /groups or /groups.json
  def index
    @groups = Group.all
  end

  # GET /groups/1 or /groups/1.json
  def show
  end

  # GET /groups/new
  def new
    @group = Group.new
  end

  # GET /groups/1/edit
  def edit
  end

  # POST /groups or /groups.json
  def create
    Rails.logger.info "[GROUP CREATE] Ontvangen params: #{params[:group].inspect}"
    @group = Group.new(group_params)
    Rails.logger.info "[GROUP CREATE] Na build: hoofdtrainer_id=#{@group.hoofdtrainer_id}, medetrainer_id=#{@group.medetrainer_id}"
    respond_to do |format|
      if @group.save
        Rails.logger.info "[GROUP CREATE] Opgeslagen: hoofdtrainer_id=#{@group.hoofdtrainer_id}, medetrainer_id=#{@group.medetrainer_id}"
        format.html { redirect_to @group, notice: "Group was successfully created." }
        format.json { render :show, status: :created, location: @group }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @group.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /groups/1 or /groups/1.json
  def update
    Rails.logger.info "[GROUP UPDATE] Ontvangen params: #{params[:group].inspect}"
    respond_to do |format|
      if @group.update(group_params)
        Rails.logger.info "[GROUP UPDATE] Opgeslagen: hoofdtrainer_id=#{@group.hoofdtrainer_id}, medetrainer_id=#{@group.medetrainer_id}"
        format.html { redirect_to @group, notice: "Group was successfully updated." }
        format.json { render :show, status: :ok, location: @group }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @group.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /groups/1 or /groups/1.json
  def destroy
    @group.destroy!

    respond_to do |format|
      format.html { redirect_to groups_path, status: :see_other, notice: "Group was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  def add_members
    @group = Group.find(params[:id])
    user_ids = params[:user_ids] || []
    if user_ids.empty?
      redirect_to @group, alert: "Selecteer minimaal één loper om toe te voegen." and return
    end
    users = User.where(id: user_ids)
    if users.empty?
      redirect_to @group, alert: "Geen geldige gebruikers geselecteerd." and return
    end
    users.each { |user| @group.add_member(user) }
    redirect_to @group, notice: "#{users.count} loper(s) toegevoegd aan de groep."
  rescue => e
    redirect_to @group, alert: "Fout bij toevoegen: #{e.message}"
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_group
      @group = Group.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def group_params
      params.require(:group).permit(:name, :hoofdtrainer_id, :medetrainer_id)
    end
end
