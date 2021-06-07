# frozen_string_literal: true

class ParkingLotService
  attr_accessor :activities

  def initialize(activities)
    @activities = activities
    @allocated_slots = 0
    @total_slots = 0
    @parking_lot = {}
    @output = ''
  end

  def call
    activities.each do |activity|
      execute(activity)
    end
    puts @output
  end

  def execute(activity)
    if activity.start_with?('Create_parking_lot')
      @total_slots = fetch_data(activity, 1).to_i
      @output += "Created parking of #{@total_slots} slots\n"
    elsif activity.start_with?('Park')
      vehicle_no = fetch_data(activity, 1)
      age = fetch_data(activity, 3)
      assign_parking_lot(vehicle_no, age)
    elsif activity.start_with?('Slot_numbers_for_driver_of_age')
      age = fetch_data(activity, 1)
      fetch_slot_numbers('age', age)
    elsif activity.start_with?('Slot_number_for_car_with_number')
      vehicle_no = fetch_data(activity, 1)
      fetch_slot_numbers('vehicle_no', vehicle_no)
    elsif activity.start_with?('Leave')
      slot = fetch_data(activity, 1).to_i
      leave_parking_slot(slot)
    elsif activity.start_with?('Vehicle_registration_number_for_driver_of_age')
      age = fetch_data(activity, 1)
      fetch_vehicle_numbers(age)
    end
  end

  def fetch_data(activity, value)
    activity.split(' ')[value]
  end

  def assign_parking_lot(vehicle_no, age)
    if @allocated_slots.zero?
      store_details(vehicle_no, age, 1)
    elsif @allocated_slots == @total_slots
      @output += "Parking Lot is full\n"
      nil
    else
      slot = 1
      while slot <= @total_slots
        unless @parking_lot.key?(slot)
          store_details(vehicle_no, age, slot)
          break
        end
        slot += 1
      end
    end
  end

  def store_details(vehicle_no, age, slot)
    p = ParkingLot.new(vehicle_no: vehicle_no, age: age)
    @parking_lot[slot] = p
    @allocated_slots += 1
    @output += "Car with vehicle registration number #{vehicle_no} has been parked at slot number #{slot}\n"
  end

  def fetch_slot_numbers(data, value)
    result = ''
    @parking_lot.each do |key, val|
      result += "#{key}," if val.send(data) == value
    end
    @output += result.empty? ? "No parked car matches the query\n" : "#{result.chop!}\n"
  end

  def leave_parking_slot(slot)
    if @parking_lot.key?(slot)
      parking_slot = @parking_lot[slot]
      age = parking_slot.age
      vehicle_no = parking_slot.vehicle_no
      @parking_lot.delete(slot)
      @output += "Slot number #{slot} vacated, the car with vehicle registration number #{vehicle_no} left the space, the driver of the car was of age #{age}\n"
    else
      @output += "Slot already vacant\n"
    end
  end

  def fetch_vehicle_numbers(age)
    result = ''
    @parking_lot.each do |_key, val|
      result += "#{val.vehicle_no}," if val.age == age
    end
    @output += result.empty? ? "No parked car matches the query\n" : "#{result.chop!}\n"
  end
end
