# -*- encoding : utf-8 -*-
class CreateEntregaSeccion < ActiveRecord::Migration
  def change
    create_table :entrega_seccion do |t|

      t.timestamps
    end
  end
end
