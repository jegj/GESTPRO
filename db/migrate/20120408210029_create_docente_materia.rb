# -*- encoding : utf-8 -*-
class CreateDocenteMateria < ActiveRecord::Migration
  def change
    create_table :docente_materia do |t|

      t.timestamps
    end
  end
end
