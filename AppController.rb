#
#  AppController.rb
#  CurrentCostStatus
#
#  Created by Rob Bevan on 23/03/2009.
#  Copyright (c) 2009 robbevan.com. All rights reserved.
#

require 'osx/cocoa'
require 'rubygems'
require 'currentcost'

include OSX

class AppController < NSObject

  ib_outlet :menu

  def awakeFromNib
    @status_bar = NSStatusBar.systemStatusBar
    @status_item = @status_bar.statusItemWithLength(NSVariableStatusItemLength)
    @status_item.setHighlightMode(true)
    @status_item.setMenu(@menu)
    set_icon('grey')
    connect_to_meter
  end
  
  def connect_to_meter
		@meter = CurrentCost::Meter.new('/dev/tty.usbserial')
		@meter.add_observer(self)
	rescue Exception => e
		NSLog(e.message)
	end

  def update(reading)
    watts = reading.total_watts
		case watts
		when 0..349
		  set_icon('green')
		when 350..999
		  set_icon('amber')
		else
		  set_icon('red')
		end
	rescue
		set_icon('grey')
	end
  
  def icon(colour)
    bundle = NSBundle.mainBundle
    NSImage.alloc.initWithContentsOfFile(bundle.pathForResource_ofType(colour, 'png'))
  end
  
  def set_icon(colour)
    @status_item.setImage(icon(colour))
  end
  
  def applicationShouldTerminate(sender)
    @meter.close
  end
end