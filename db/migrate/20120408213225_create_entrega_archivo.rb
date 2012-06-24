# -*- encoding : utf-8 -*-
class CreateEntregaArchivo < ActiveRecord::Migration
  def change
    create_table :entrega_archivo do |t|

      t.timestamps
    end
  end
end
