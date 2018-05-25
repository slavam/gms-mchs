module PollutionValuesHelper
  def get_digits(n)
    ndigits = []
    ndigits[1] = 2
    ndigits[2] = 3
    ndigits[4] = 0
    ndigits[5] = 2
    ndigits[6] = 2
    ndigits[10] = 3
    ndigits[19] = 2
    ndigits[22] = 3
    return ndigits[n] || 2
  end
  
end
