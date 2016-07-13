<script language="javascript" type="text/javascript" src="/library/moment/moment.min.js"></script>
<script language="javascript" type="text/javascript" src="/library/fullcalendar/fullcalendar.min.js"></script>
<script language="javascript" type="text/javascript" src="/library/fullcalendar/lang-all.js"></script>

<script>

var new_event = [];
var new_event_id = Math.random().toString(36).substring(7);

$(document).ready(function() {
	$('#calendar').fullCalendar({
		eventSources: [ {{$sources}} ],

		header: false,

		lang: '{{$lang}}',
		firstDay: {{$first_day}},

		monthNames: aStr['monthNames'],
		monthNamesShort: aStr['monthNamesShort'],
		dayNames: aStr['dayNames'],
		dayNamesShort: aStr['dayNamesShort'],
		allDayText: aStr['allday'],

		timeFormat: 'HH:mm',
		defaultTimedEventDuration: '01:00:00',

		dayClick: function(date, jsEvent, view) {

			if(new_event.length)
				$('#calendar').fullCalendar( 'removeEventSource', new_event);

			$('.section-content-tools-wrapper').show();

			$('#event_uri').val('');
			$('#id_title').val('New event');
			$('#calendar_select').val($("#calendar_select option:first").val()).attr('disabled', false);
			$('#static_target').val('');
			$('#id_dtstart').val(date.format());
			$('#id_dtend').val(date.hasTime() ? date.add(1, 'hours').format() : '');
			$('#event_submit').val('create_event').html('Create');
			$('#event_delete').hide();

			new_event = [{ id: new_event_id, title  : 'New event', start: $('#id_dtstart').val(), end: $('#id_dtend').val(), editable: true, color: '#bbb' }]
			$('#calendar').fullCalendar( 'addEventSource', new_event);
		},

		eventClick: function(event, jsEvent, view) {

			if(event.id == new_event_id) {
				$(window).scrollTop(0);
				$('#id_title').focus().val('');
				return false;
			}

			if(new_event.length && event.source.editable)
				$('#calendar').fullCalendar( 'removeEventSource', new_event);

			if(event.source.editable) {
				$('.section-content-tools-wrapper').show();
				$('#event_uri').val(event.uri);
				$('#id_title').val(event.title);
				$('#calendar_select').val(event.calendar_id[0] + ':' + event.calendar_id[1]).attr('disabled', true);
				$('#static_target').val(event.calendar_id[0] + ':' + event.calendar_id[1]);
				$('#id_dtstart').val(event.start.format());
				$('#id_dtend').val(event.end ? event.end.format() : '');
				$('#event_submit').val('update_event').html('Update');
				$('#event_delete').show();
			}
		},

		eventResize: function(event, delta, revertFunc) {

			$('#id_title').val(event.title);
			$('#id_dtstart').val(event.start.format());
			$('#id_dtend').val(event.end.format());

			$.post( 'cdav/calendar', {
				'update': 'dt',
				'id[]': event.calendar_id,
				'uri': event.uri,
				'dtstart': event.start ? event.start.format() : '',
				'dtend': event.end ? event.end.format() : ''
			})
			.fail(function() {
				revertFunc();
			});
		},

		eventDrop: function(event, delta, revertFunc) {

			$('#id_title').val(event.title);
			$('#id_dtstart').val(event.start.format());
			$('#id_dtend').val(event.end ? event.end.format() : '');

			$.post( 'cdav/calendar', {
				'update': 'dt',
				'id[]': event.calendar_id,
				'uri': event.uri,
				'dtstart': event.start ? event.start.format() : '',
				'dtend': event.end ? event.end.format() : ''
			})
			.fail(function() {
				revertFunc();
			});
		},

		loading: function(isLoading, view) {
			$('#events-spinner').spin('tiny');
			$('#events-spinner > i').css('color', 'transparent');
			if(!isLoading) {
				$('#events-spinner').spin(false);
				$('#events-spinner > i').css('color', '');
			}
		}
	});

	// echo the title
	var view = $('#calendar').fullCalendar('getView');
	$('#title').text(view.title);

	$('.color-edit').colorpicker({ input: '.color-edit-input' });

	$(document).on('click','#fullscreen-btn', on_fullscreen);
	$(document).on('click','#inline-btn', on_inline);

	$(document).on('click','#event_cancel', on_cancel);
	$(document).on('click','#event_more', on_more);
});

function changeView(action, viewName) {
	$('#calendar').fullCalendar(action, viewName);
	var view = $('#calendar').fullCalendar('getView');
	if(view.type !== 'month' && !$('main').hasClass('fullscreen')) {
		$('#calendar').fullCalendar('option', 'height', 'auto');
	}
	else {
		$('#calendar').fullCalendar('option', 'height', '');
	}

	if($('main').hasClass('fullscreen')) {
		$('#calendar').fullCalendar('option', 'height', $(window).height() - $('.section-title-wrapper').outerHeight(true) - 2); // -2 is for border width (.generic-content-wrapper top and bottom) of .generic-content-wrapper
	}

	$('#title').text(view.title);
}

function add_remove_json_source(source, color, editable, status) {

	if(status === undefined)
		status = 'fa-calendar-check-o';

	if(status === 'drop') {
		$('#calendar').fullCalendar( 'removeEventSource', source );
		return;
	}

	var parts = source.split('/');
	var id = parts[4];

	var selector = '#calendar-btn-' + id;

	if($(selector).hasClass('fa-calendar-o')) {
		$('#calendar').fullCalendar( 'addEventSource', { url: source, color: color, editable: editable });
		$(selector).removeClass('fa-calendar-o');
		$(selector).addClass(status);
		$.get('/cdav/calendar/switch/' + id + '/1');
	}
	else {
		$('#calendar').fullCalendar( 'removeEventSource', source );
		$(selector).removeClass(status);
		$(selector).addClass('fa-calendar-o');
		$.get('/cdav/calendar/switch/' + id + '/0');
	}
}

function on_fullscreen() {
	$('#calendar').fullCalendar('option', 'height', $(window).height() - $('.section-title-wrapper').outerHeight(true) - 2); // -2 is for border width (.generic-content-wrapper top and bottom) of .generic-content-wrapper
}

function on_inline() {
	var view = $('#calendar').fullCalendar('getView');
	((view.type === 'month') ? $('#calendar').fullCalendar('option', 'height', '') : $('#calendar').fullCalendar('option', 'height', 'auto'));
}

function on_cancel() {
	if(new_event.length) {
		$('#calendar').fullCalendar( 'removeEventSource', new_event);
	}
	$('.section-content-tools-wrapper').hide();
	$('#id_title').val('');
	$('#id_dtstart').val('');
	$('#id_dtend').val('');
}

function on_more() {
	if($('#more_block').hasClass('open')) {
		$('#event_more').html('<i class="fa fa-caret-down"></i> More');
		$('#more_block').removeClass('open').hide();
	}
	else {
		$('#event_more').html('<i class="fa fa-caret-up"></i> Less');
		$('#more_block').addClass('open').show();
	}
}
</script>

<div class="generic-content-wrapper">
	<div class="section-title-wrapper">
		<div class="pull-right">
			<div class="dropdown">
				<button type="button" class="btn btn-default btn-xs dropdown-toggle" data-toggle="dropdown"><i class="fa fa-caret-down"></i>&nbsp;{{$view_label}}</button>
				<ul class="dropdown-menu">
					<li><a href="#" onclick="changeView('changeView', 'month'); return false;">{{$month}}</a></li>
					<li><a href="#" onclick="changeView('changeView', 'agendaWeek'); return false;">{{$week}}</a></li>
					<li><a href="#" onclick="changeView('changeView', 'agendaDay'); return false;">{{$day}}</a></li>
				</ul>
				<div class="btn-group">
					<button class="btn btn-default btn-xs" onclick="changeView('prev', false);" title="{{$prev}}"><i class="fa fa-backward"></i></button>
					<button id="events-spinner" class="btn btn-default btn-xs" onclick="changeView('today', false);" title="{{$today}}"><i class="fa fa-bullseye"></i></button>
					<button class="btn btn-default btn-xs" onclick="changeView('next', false);" title="{{$next}}"><i class="fa fa-forward"></i></button>
				</div>
				<button id="fullscreen-btn" type="button" class="btn btn-default btn-xs" onclick="makeFullScreen();"><i class="fa fa-expand"></i></button>
				<button id="inline-btn" type="button" class="btn btn-default btn-xs" onclick="makeFullScreen(false);"><i class="fa fa-compress"></i></button>
			</div>
		</div>
		<h2 id="title"></h2>
		<div class="clear"></div>
	</div>
	<div class="section-content-tools-wrapper" style="display: none">
		<form method="post" action="">
			<input id="event_uri" type="hidden" name="uri" value="">
			{{include file="field_input.tpl" field=$title}}
			<label for="calendar_select">Select calendar</label>
			<select id="calendar_select" name="target" class="form-control form-group">
				{{foreach $writable_calendars as $writable_calendar}}
				<option value="{{$writable_calendar.id.0}}:{{$writable_calendar.id.1}}">{{$writable_calendar.displayname}}</option>
				{{/foreach}}
			</select>
			<input id="static_target" type="hidden" name="static_target" value="">
			<div id="more_block" style="display: none;">
				{{include file="field_input.tpl" field=$dtstart}}
				{{include file="field_input.tpl" field=$dtend}}
			</div>
			<div class="form-group">
				<div class="pull-right">
					<button id="event_submit" type="submit" name="submit" value="" class="btn btn-primary btn-sm"></button>
					<button id="event_cancel" type="button" class="btn btn-default btn-sm">Cancel</button>
				</div>
				<div>
					<button id="event_delete" type="submit" name="delete" value="delete" class="btn btn-danger btn-sm">Delete</button>
					<button id="event_more" type="button" class="btn btn-default btn-sm"><i class="fa fa-caret-down"></i> More</button>
				</div>
				<div class="clear"></div>
			</div>
		</form>
	</div>
	<div class="section-content-wrapper-np">
		<div id="calendar"></div>
	</div>
</div>
