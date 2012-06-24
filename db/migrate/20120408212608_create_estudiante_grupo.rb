# -*- encoding : utf-8 -*-
class CreateEstudianteGrupo < ActiveRecord::Migration
  def change
    create_table :estudiante_grupo do |t|

      t.timestamps
    end
  end
end
