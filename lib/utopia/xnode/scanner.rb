
require 'strscan'

module Utopia
	module XNode
		class ScanError < StandardError
			def initialize(message, scanner = nil)
				if scanner
					message = message + ": %p" % scanner
				end
			
				super(message)
			end
		end
	
		class Scanner < StringScanner
			CDATA = /[^<]+/m
			TAG_PARAMETER = /\s*([^\s=\/>]*)=((['"])(.*?)\3)/um

			def initialize(callback, string)
				@callback = callback
				super(string)
			end

			def parse
				until eos?
					pos = self.pos

					scan_cdata
					scan_tag

					if pos == self.pos
						raise ScanError.new("Scanner didn't move", self)
					end
				end
			end
		
			def scan_cdata
				if scan(CDATA)
					@callback.cdata(matched)
				end
			end
		
			def scan_tag
				if scan(/</)
					if scan(/\//)
						scan_tag_normal(CLOSED_TAG)
					elsif scan(/!/)
						scan_tag_comment
					elsif scan(/\?/)
						scan_tag_instruction
					else
						scan_tag_normal
					end
				end
			end
		
			def scan_attributes
				while scan(TAG_PARAMETER)
					@callback.attribute(self[1], self[4])
				end
			end
		
			def scan_tag_normal(begin_tag_type = OPENED_TAG)
				if scan(/[^\s\/>]+/)
					@callback.begin_tag(matched, begin_tag_type)
				
					scan(/\s*/)
				
					scan_attributes
				
					scan(/\s*/)
				
					if scan(/\/>/)
						if begin_tag_type == CLOSED_TAG
							raise ScanError.new("Tag cannot be closed at both ends!", self)
						else
							@callback.finish_tag(begin_tag_type, CLOSED_TAG)
						end
					elsif scan(/>/)
						@callback.finish_tag(begin_tag_type, OPENED_TAG)
					else
						raise ScanError.new("Invalid characters in tag!", self)
					end
				else
					raise ScanError.new("Invalid tag!", self)
				end
			end
		
			def scan_tag_comment
				if scan(/--/)
					if scan_until(/(.*?)-->/m)
						@callback.comment("--" + self[1] + "--")
					else
						raise ScanError.new("Comment is not closed!", self)
					end
				else
					if scan_until(/(.*?)>/)
						@callback.comment(self[1])
					else
						raise ScanError.new("Comment is not closed!", self)
					end
				end
			end
		
			def scan_tag_instruction
				if scan_until(/(.*)\?>/)
					@callback.instruction(self[1])
				end
			end
		end
	end
end
