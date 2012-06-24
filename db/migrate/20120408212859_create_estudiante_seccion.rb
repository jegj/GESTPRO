# -*- encoding : utf-8 -*-
class CreateEstudianteSeccion < ActiveRecord::Migration
  def change
    create_table :estudiante_seccion do |t|

      t.timestamps
    end
  end
end
