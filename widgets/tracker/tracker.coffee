class Dashing.Tracker extends Dashing.Widget
  onData: (data) ->
    $(@node).toggleClass('passed', data.passed)
    $(@node).toggleClass('failed', !data.passed)
    $(@node).toggleClass('pending', data.pending)