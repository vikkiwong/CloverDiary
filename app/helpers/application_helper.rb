module ApplicationHelper
	def shown_time(cur_time)
    if cur_time.is_a?(Time)
      cur_time.strftime("%Y-%m-%d %H:%M")
    else
      ""
    end
  end

	def shown_time_hm(cur_time)
    if cur_time.is_a?(Time)
      cur_time.strftime("%H:%M")
    else
      ""
    end
  end
end
