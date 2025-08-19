class Esim
  def data
    JSON.load_file("public/mock_orders_5.json")
  end
end