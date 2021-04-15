ActiveRecord::Schema.define(version: 0) do
  create_table :users do |t|
    t.string :email, :name
    t.numeric :salary, :bonus
  end
end
