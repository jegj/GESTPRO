# -*- encoding : utf-8 -*-
class CreateEntregableArchivo < ActiveRecord::Migration
  def change
    create_table :entregable_archivo do |t|

      t.timestamps
    end
  end
end
