# -*- encoding : utf-8 -*-
class CreateMateria < ActiveRecord::Migration
  def change
    create_table :materia do |t|

      t.timestamps
    end
  end
end
