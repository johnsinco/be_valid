ActiveRecord::Schema.define(version: 0) do
  create_table :users do |t|
    t.string :email, :name, :letters
    t.numeric :salary, :bonus
    t.date :birthday, :naming_day
  end
end
