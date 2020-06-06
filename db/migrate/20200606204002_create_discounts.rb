class CreateDiscounts < ActiveRecord::Migration[5.1]
  def change
    create_table :discounts do |t|
      t.references :merchant, foreign_key: true
      t.float :percent_discount
      t.integer :minimum_quantity
      t.integer :minimum_value
      t.timestamps
    end
  end
end
