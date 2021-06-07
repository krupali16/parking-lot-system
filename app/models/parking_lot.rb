class ParkingLot
  attr_accessor :vehicle_no, :age

  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end
  end
end
