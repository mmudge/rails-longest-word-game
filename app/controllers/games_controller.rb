require 'open-uri'
require 'json'

class GamesController < ApplicationController

  def new
    @letters = generate_grid(10)
    @start_time = Time.now
  end

  def score
    @letters = params[:grid]
    @start_time = Time.parse(params[:start_time])
    @end_time = Time.now
    @attempt = params[:attempt]
    @results = run_game(@attempt, @letters, @start_time, @end_time)
  end

  def generate_grid(grid_size)
    # TODO: generate random grid of letters, random letters between A-Z
    return (0...grid_size).map { ('A'..'Z').to_a[rand(26)] }
  end

  def check_word_with_grid(attempt, grid)
    letters = attempt.split('')
    grid_array = grid.split('')
    count = 0
    letters.each do |letter|
      if grid_array.include?(letter.upcase)
        grid_array.delete_at(grid_array.index(letter.upcase))
        count += 1
      end
    end
    return count == attempt.length
  end

  def run_game(attempt, grid, start_time, end_time)
    result = { time: end_time - start_time, score: 0, message: "Well done!" }
    online_check = JSON.parse(open("https://wagon-dictionary.herokuapp.com/#{attempt}").read)
    return check_result(online_check, result, attempt, grid)
  end

  def check_result(online_check, result, attempt, grid)
    if check_word_with_grid(attempt, grid) && online_check["found"]
      result[:score] += attempt.length
      result[:score] -= (result[:time] / 8)
    elsif !online_check["found"] # && check_word_with_grid(attempt, grid)
      result[:message] = "The given word is not an english word!"
    else
      result[:message] = "The given word is not in the grid!"
    end
    return result
  end
end
