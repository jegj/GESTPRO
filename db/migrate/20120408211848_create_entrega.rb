# -*- encoding : utf-8 -*-
class CreateEntrega < ActiveRecord::Migration
  def change
    create_table :entrega do |t|

      t.timestamps
    end
  end
end
