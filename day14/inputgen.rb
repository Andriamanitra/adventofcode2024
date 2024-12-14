# script to generate puzzle input from an ASCII art text file
# Usage: ruby inputgen.rb <asciiart.txt >custom-input.txt

# character used for the filled squares in the ascii art file
FILLED = '░'
WIDTH = 101
HEIGHT = 103
STEPS_REQUIRED = rand(1000..1880)
RANDOM_ROBOTS = 100
SPEED_RANGE = -99..99

X_RANGE = 0...WIDTH
Y_RANGE = 0...HEIGHT

lines = ARGF.readlines(chomp: true)
robots = []
lines.take(HEIGHT).each_with_index do |row, r|
  row.chars.take(WIDTH).each_with_index do |ch, c|
    if ch == FILLED
      robots.push([c, r, rand(SPEED_RANGE), rand(SPEED_RANGE)])
    end
  end
end

# add a few random robots to spice things up
RANDOM_ROBOTS.times do
  robots.push([rand(X_RANGE), rand(Y_RANGE), rand(SPEED_RANGE), rand(SPEED_RANGE)])
end

robots.each do |x, y, dx, dy|
  x = (x - dx * STEPS_REQUIRED) % WIDTH
  y = (y - dy * STEPS_REQUIRED) % HEIGHT
  puts "p=#{x},#{y} v=#{dx},#{dy}"
end

$stderr.puts "number of robots = #{robots.size}"
$stderr.puts "steps to find the answer = #{STEPS_REQUIRED}"
