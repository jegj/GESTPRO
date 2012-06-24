# -*- encoding : utf-8 -*-
class CreateGrupo < ActiveRecord::Migration
  def change
    create_table :grupo do |t|

      t.timestamps
    end
  end
end
