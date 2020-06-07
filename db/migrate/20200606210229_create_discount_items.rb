class CreateDiscountItems < ActiveRecord::Migration[5.1]
  def change
    create_table :discount_items do |t|
      t.references :discount, foreign_key: true
      t.references :item, foreign_key: true
      t.timestamps 
    end
  end
end
