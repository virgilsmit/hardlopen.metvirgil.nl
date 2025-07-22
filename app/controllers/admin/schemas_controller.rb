module Admin
  class SchemasController < ApplicationController
    def koppelen
      @groups = Group.all
      @schemas = TrainingSchema.all
      if request.post?
        schema = TrainingSchema.find_by(id: params[:schema_id])
        group = Group.find_by(id: params[:group_id])
        if schema && group
          schema.update(group_id: group.id)
          flash[:notice] = "Schema '#{schema.name}' is succesvol gekoppeld aan groep '#{group.name}'."
          redirect_to admin_schemas_koppelen_path and return
        else
          flash.now[:alert] = "Ongeldige selectie."
        end
      end
    end

    def rename
      schema = TrainingSchema.find_by(id: params[:schema_id])
      if schema && params[:new_name].present?
        schema.update(name: params[:new_name])
        flash[:notice] = "Schema hernoemd naar '#{schema.name}'."
      else
        flash[:alert] = "Hernoemen mislukt."
      end
      redirect_to admin_schemas_koppelen_path
    end
  end
end 