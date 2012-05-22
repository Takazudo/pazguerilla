# intancify template manager
# http://hamalog.tumblr.com/post/13593032409/jquery-tmpldeck

deck = $.TmplDeck 'templates.html'

# ============================================
# utils
# ============================================

today =
  month: (new Date).getMonth() + 1
  day: (new Date).getDate()

isToday = (dateStr) ->
  # dateStr is like "5/10"
  return unless dateStr.match(/^\d+/)[0]*1 is today.month
  return unless dateStr.match(/\d+$/)[0]*1 is today.day
  true
  
$.fn.disableTd = (group) ->
  @each ->
    $(@).removeClass 'active'

$.fn.enableTd = (group) ->
  @each ->
    $td = $(@)
    return unless $td.data('group') is group
    $td.addClass 'active'

$.fn.rememberGroup = ->
  disableAll = ->
    $('td:not(.type)').disableTd()
  enable = (group) ->
    $('td:not(.type)').enableTd(group)
  @each ->
    $el = $(@)
    $el.click ->
      group = $el.data 'group'
      disableAll()
      enable group
      localStorage.setItem 'mygroup', group
      

# ============================================
# API wrapper
# ============================================

# namespace

api = {}

api.fetchData = (query) ->
  $.Deferred (defer) ->
    $.ajax
      url: 'http://api.konolog.net/pad/'
      dataType: 'jsonp'
    .pipe (res) ->
      defer.resolve res
    , ->
      defer.reject()
  .promise()

# ============================================
# Models
# ============================================

class Guerilla extends Backbone.Model
  fetch: ->
    $.Deferred (defer) ->
      api.fetchData().then (data) ->
        defer.resolve data
      , ->
        defer.reject()
  update: ->
    $.Deferred (defer) =>
      @fetch().then (data) =>
        @_handleFetchedData data
        @trigger 'update'
      , =>
        @trigger 'error'
  _handleFetchedData: (data) ->
    
    # handle today
    _.each data, (day, i) ->
      return unless isToday day[0]
      day.today = true

    # convert M,G
    _.each data, (day, i) ->
      type = day[6]
      switch type
        when 'M' then day[6] = 'ﾒﾀﾄﾞﾗ'
        when 'G' then day[6] = 'ｺﾞﾙﾄﾞﾗ'

    @set 'days', data
    @

guerilla = new Guerilla


# ============================================
# Views
# ============================================

class AppView extends Backbone.View
  initialize: ->
    guerilla.bind 'update', => @renderData()
    guerilla.bind 'error', => @renderError()
    @
  renderData: ->
    @$el.html( deck.tmpl 'table', guerilla.toJSON() )
    @_initInside()
    @
  renderError: ->
    @$el.html( deck.draw 'error' )
    @_initInside()
    @
  _initInside: ->
    @$('td:not(.type)').rememberGroup()
    cachedGroup = localStorage.getItem 'mygroup'
    return @ unless cachedGroup?
    @$('td:not(.type)').enableTd cachedGroup
    @

# ============================================
# Do it
# ============================================

deck.load().done ->
  $ ->
    view = new AppView el: $('#root')
    guerilla.update()
