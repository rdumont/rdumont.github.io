module Jekyll
	module ExcerptFilter
		def excerpt(content)
			content.split('<!--more-->')[0]
		end
	end
end

Liquid::Template.register_filter(Jekyll::ExcerptFilter)