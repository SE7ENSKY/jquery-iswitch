###
@name jquery-iswitch
@description Reinvent the iOS-style switch.
@version 1.0.2
@author Se7enSky studio <info@se7ensky.com>
###

###! jquery-iswitch 1.0.2 http://github.com/Se7enSky/jquery-iswitch###

plugin = ($) ->

	"use strict"

	class ISwitch
		defaults: {}

		constructor: (@el, config) ->
			@$el = $ @el
			@$body = $("body")
			@config = $.extend {}, @defaults, config
			@preventClick = off
			@pwnCheckbox()
			@manualSwitchEvents()

		pwnCheckbox: ->
			@$el.hide()
			@$handle = $('<i class="iswitch__handle"></i>')
			@$container = $('<ins class="iswitch__container"></ins>').append @$handle
			@$container.on "click", =>
				if @preventClick
					@preventClick = off
				else
					@toggle()
			@$el.change => @updateOnOff()
			@updateOnOff()
			@$el.after @$container

		toggle: ->
			@$el.prop("checked", not @$el.prop "checked").trigger("change")

		updateOnOff: ->
			checked = @$el.prop "checked"
			if checked
				@$handle.addClass("iswitch__handle_on").removeClass("iswitch__handle_off")
				@$container.addClass("iswitch__container_on").removeClass("iswitch__container_off")
			else
				@$handle.addClass("iswitch__handle_off").removeClass("iswitch__handle_on")
				@$container.addClass("iswitch__container_off").removeClass("iswitch__container_on")

		manualSwitchEvents: ->
			@$handle.on 'mousedown', (e) =>
				e.preventDefault()
				@$handle.addClass "iswitch__handle_manual"
				startX = event.pageX or event.originalEvent.changedTouches[0].pageX
				startMargin = parseFloat @$handle.css("margin-left").replace("px", "")
				checked = @$el.prop "checked"
				marginMin = 0
				marginMax = parseFloat(@$container.css("width").replace("px", "")) - parseFloat(@$container.css("padding-left").replace("px", "")) - parseFloat(@$container.css("padding-right").replace("px", "")) - parseFloat(@$handle.css("width").replace("px", ""))
				mousemoveHandler = (e) =>
					@preventClick = on
					e.preventDefault()
					dx = startX - (event.pageX or event.originalEvent.changedTouches[0].pageX)
					margin = Math.max marginMin, Math.min marginMax, startMargin - dx
					@$handle.css marginLeft: "#{margin}px"
					checked = margin > (marginMin + marginMax) / 2
					@$el.prop("checked", checked).trigger("change")
				@$body.on "mousemove", mousemoveHandler
				@$body.one "mouseup", (e) =>
					e.preventDefault()
					@$body.off "mousemove", mousemoveHandler
					@$handle.css marginLeft: ''
					@$handle.removeClass "iswitch__handle_manual"
					@$el.prop("checked", checked).trigger("change")

		destroy: ->
			@$el.show()
			@$handle.remove()
			@$container.remove()

	$.fn.iswitch = (method, args...) ->
		@each ->
			iswitch = $(@).data 'iswitch'
			unless iswitch
				iswitch = new ISwitch @, if typeof method is 'object' then method else {}
				$(@).data 'iswitch', iswitch

			iswitch[method].apply iswitch, args if typeof method is 'string'

# UMD
if typeof define is 'function' and define.amd # AMD
	define(['jquery'], plugin)
else # browser globals
	plugin(jQuery)
