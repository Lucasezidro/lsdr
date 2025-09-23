require "faker"

puts "Limpando dados existentes..."
Address.destroy_all
User.destroy_all
Organization.destroy_all
Goal.destroy_all
Transaction.destroy_all

puts "Criando organização de exemplo..."
organization = Organization.create!(
  company_name: "Empresa de Gestão",
  corporate_name: "Empresa de Gestão Ltda.",
  document_number: Faker::Company.brazilian_company_number,
  email: "contato@empresa.com",
  phone_number: Faker::PhoneNumber.phone_number,
  founding_date: Faker::Date.backward(days: 365 * 5),
  website_url: "http://empresa.com",
  description: Faker::Company.bs,
)

puts "Criando usuário ADMIN..."
admin = User.create!(
  name: "Administrador",
  email: "admin@empresa.com",
  password: "password123",
  password_confirmation: "password123",
  role: "ADMIN",
  occupation: "CEO",
  salary: Faker::Commerce.price(range: 10000..30000),
  phone_number: Faker::PhoneNumber.phone_number,
  organization: organization,
)

puts "Criando usuário MANAGER..."
manager = User.create!(
  name: "Gerente",
  email: "manager@empresa.com",
  password: "password123",
  password_confirmation: "password123",
  role: "MANAGER",
  occupation: "Gerente de Projetos",
  salary: Faker::Commerce.price(range: 8000..15000),
  phone_number: Faker::PhoneNumber.phone_number,
  organization: organization,
  manager: admin,
)

puts "Criando 5 funcionários..."
5.times do
  User.create!(
    name: Faker::Name.name,
    email: Faker::Internet.email,
    password: "password123",
    password_confirmation: "password123",
    role: "EMPLOYEE",
    occupation: Faker::Job.title,
    salary: Faker::Commerce.price(range: 2000..5000),
    phone_number: Faker::PhoneNumber.phone_number,
    organization: organization,
    manager: manager,
  )
end

puts "Criando metas de exemplo..."
3.times do
  Goal.create!(
    title: Faker::Hobby.activity,
    description: Faker::Lorem.sentence(word_count: 10),
    due_date: Faker::Date.between(from: Date.today, to: 1.year.from_now),
    status: ["in_progress", "finished"].sample,
    target_amount: Faker::Commerce.price(range: 10000..100000),
    organization: organization,
    goal_type: "company_goal"
  )
end

puts "Criando transações de exemplo..."
10.times do
  Transaction.create!(
    description: Faker::Commerce.product_name,
    amount: Faker::Commerce.price(range: 100..5000),
    transaction_type: ["income", "expense"].sample,
    date: Faker::Date.between(from: 3.months.ago, to: Date.today),
    organization: organization,
  )
end

puts "Seed concluído com sucesso!"