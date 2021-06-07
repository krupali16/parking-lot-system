namespace :create_parking_lot do
  task run: :environment do
    file = File.open(Rails.root.join('public/', 'input.txt'))
    file_data = file.readlines.map(&:chomp)
    file.close
    ::ParkingLotService.new(file_data).call
  end
end
