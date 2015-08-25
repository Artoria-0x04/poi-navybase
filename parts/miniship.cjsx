{relative, join} = require 'path-extra'
{_, $, $$, React, ReactBootstrap, ROOT, toggleModal} = window
{$ships, $shipTypes, _ships} = window
{Button, ButtonGroup} = ReactBootstrap
{ProgressBar, OverlayTrigger, Tooltip, Alert, Overlay, Label, Panel, Popover} = ReactBootstrap

inBattle = [false, false, false, false]
getStyle = (state) ->
  if state in [0..5]
    # 0: Cond >= 40, Supplied, Repaired, In port
    # 1: 20 <= Cond < 40, or not supplied, or medium damage
    # 2: Cond < 20, or heavy damage
    # 3: Repairing
    # 4: In mission
    # 5: In map
    return ['success', 'warning', 'danger', 'info', 'default', 'primary'][state]
  else
    return 'default'

getDeckState = (deck) ->
  state = 0
  {$ships, _ships} = window
  # In mission
  if inBattle[deck.api_id - 1]
    state = Math.max(state, 5)
  if deck.api_mission[0] > 0
    state = Math.max(state, 4)
  for shipId in deck.api_ship
    continue if shipId == -1
    ship = _ships[shipId]
    shipInfo = $ships[ship.api_ship_id]
    # Cond < 20 or medium damage
    if ship.api_cond < 20 || ship.api_nowhp / ship.api_maxhp < 0.25
      state = Math.max(state, 2)
    # Cond < 40 or heavy damage
    else if ship.api_cond < 40 || ship.api_nowhp / ship.api_maxhp < 0.5
      state = Math.max(state, 1)
    # Not supplied
    if ship.api_fuel / shipInfo.api_fuel_max < 0.99 || ship.api_bull / shipInfo.api_bull_max < 0.99
      state = Math.max(state, 1)
    # Repairing
    if shipId in window._ndocks
      state = Math.max(state, 3)
  state

getHpStyle = (percent) ->
  if percent <= 25
    'danger'
  else if percent <= 50
    'warning'
  else if percent <= 75
    'primary'
  else
    'success'

getMaterialStyle = (percent) ->
  if percent <= 50
    'danger'
  else if percent <= 75
    'warning'
  else if percent < 100
    'primary'
  else
    'success'

getCondStyle = (cond) ->
  if cond > 84
    '#FCEB00'
  else if cond > 49
    '#FFBF00'
  else if cond < 20
    '#DD514C'
  else if cond < 30
    '#F37B1D'
  else if cond < 40
    '#FFC880'
  else
    '#FFF'

getFontStyle = (theme)  ->
  if window.isDarkTheme then color: '#FFF' else color: '#000'

getStatusStyle = (status) ->
  # flag = status.reduce (a, b) -> a or b
  if status?
    flag = status[0] or status[1] # retreat or repairing
    if flag? and flag
      return {opacity: 0.4}
    else
      return {}
    # $("#ShipView #shipInfo").style.opacity = 0.4

getStatusArray = (shipId) ->
  status = []
  # retreat status
  status[0] = false
  # reparing
  status[1] = if shipId in _ndocks then true else false
  # special 1 locked phase 1
  status[2] = if _ships[shipId].api_sally_area == 1 then true else false
  # special 2 locked phase 2
  status[3] = if _ships[shipId].api_sally_area == 2 then true else false
  # special 3 locked phase 3
  status[4] = if _ships[shipId].api_sally_area == 3 then true else false
  # special 3 locked phase 3
  status[5] = if _ships[shipId].api_sally_area == 4 then true else false
  return status
###
# usage:
# get a ship's all status using props, sorted by status priority
# status array: [retreat, repairing, special1, special2, special3]
# value: boolean

      <Label bsStyle="info"><FontAwesome key={0} name='asterisk' /></Label>
    else if @props.status[3]? and @props.status[3]
      <Label bsStyle="primary"><FontAwesome key={0} name='heart' /></Label>
    else if @props.status[4]? and @props.status[4]
      <Label bsStyle="success"><FontAwesome key={0} name='leaf' /></Label>
    else if @props.status[4]? and @props.status[4]
      <Label bsStyle="warning"><FontAwesome key={0} name='rub' /></Label>

    @todo: improve extesibility
###
StatusLabelMini = React.createClass
  shouldComponentUpdate: (nextProps, nextState) ->
    not _.isEqual(nextProps.label, @props.label)
  render: ->
    if @props.label[0]? and @props.label[0]
      <Label bsStyle="danger"><FontAwesome key={0} name='exclamation-circle' /></Label>
    else if @props.label[1]? and @props.label[1]
      <Label bsStyle="info"><FontAwesome key={0} name='wrench' /></Label>
    else if @props.label[2]? and @props.label[2]
      <Label bsStyle="info"><FontAwesome key={0} name='lock' /></Label>
    else if @props.label[3]? and @props.label[3]
      <Label bsStyle="primary"><FontAwesome key={0} name='lock' /></Label>
    else if @props.label[4]? and @props.label[4]
      <Label bsStyle="success"><FontAwesome key={0} name='lock' /></Label>
    else if @props.label[4]? and @props.label[4]
      <Label bsStyle="warning"><FontAwesome key={0} name='lock' /></Label>
    else
      <Label bsStyle="default" style={border:"1px solid "}></Label>

###
@todo: reset timer
###
RecoveryBar = React.createClass
  getInitialState: ->
    elapsed: 0
  updateCountdown: ->
    @setStaship-details
      elapsed: @state.elapsed + 1000
  componentWillUnmount: ->
    @interval = clearInterval @interval
  componentDidMount: ->
    @interval = setInterval @updateCountdown, 1000 if !@interval?
    if @props.repairTimer.remain? and @state.elapsed - @props.repairTimer.remain < 0
      $("#MiniShip .rec-progress-#{@props.deckIndex}.progress-bar").style.backgroundColor = "#28BDF4"
    else if @props.missionTimer.remain? and@state.elapsed - @props.missionTimer.remain < 0
      $("#MiniShip .rec-progress-#{@props.deckIndex}.progress-bar").style.backgroundColor = "#747474"
    else if @props.condTimer.remain? and @state.elapsed - @props.condTimer.remain < 0
      $("#MiniShip .rec-progress-#{@props.deckIndex}.progress-bar").style.backgroundColor = "#F4CD28"
    else
      $("#MiniShip .rec-progress-#{@props.deckIndex}.progress-bar").style.backgroundColor = "#7FC135"
  componentDidUpdate: (prevProps, prevState) ->
    if @props.repairTimer.remain? and @state.elapsed - @props.repairTimer.remain < 0
      $("#MiniShip .rec-progress-#{@props.deckIndex}.progress-bar").style.backgroundColor = "#28BDF4"
    else if @props.missionTimer.remain? and @state.elapsed - @props.missionTimer.remain < 0
      $("#MiniShip .rec-progress-#{@props.deckIndex}.progress-bar").style.backgroundColor = "#747474"
    else if @props.condTimer.remain? and @state.elapsed - @props.condTimer.remain < 0
      $("#MiniShip .rec-progress-#{@props.deckIndex}.progress-bar").style.backgroundColor = "#F4CD28"
    else
      $("#MiniShip .rec-progress-#{@props.deckIndex}.progress-bar").style.backgroundColor = "#7FC135"
  render: ->
    if @props.repairTimer.remain? and @state.elapsed - @props.repairTimer.remain < 0
      <ProgressBar key={1} className="rec-progress-#{@props.deckIndex}"
      now={
        if @state.elapsed - @props.repairTimer.remain < 0
          (@props.repairTimer.total - @props.repairTimer.remain - 60000 + @state.elapsed) / @props.repairTimer.total * 100
        else
          100
        } />
    else if @props.missionTimer.remain? and @state.elapsed - @props.missionTimer.remain < 0
      <ProgressBar key={1} className="rec-progress-#{@props.deckIndex}"
      now={
        if @state.elapsed - @props.missionTimer.remain < 0
          (@props.missionTimer.total - @props.missionTimer.remain + @state.elapsed) / @props.missionTimer.total * 100
        else
          100
        } />
    else if @props.condTimer.remain? and @state.elapsed - @props.condTimer.remain < 0
      <ProgressBar key={1} className="rec-progress-#{@props.deckIndex}"
      now={
        if @state.elapsed - @props.condTimer.remain< 0
          (@props.condTimer.total - @props.condTimer.remain + @state.elapsed) / @props.condTimer.total * 100
        else
          100
        } />
    else
      <ProgressBar key={1} className="rec-progress" id="rec-progress-#{@props.deckIndex}" now={100} />

getBackdropStyle = ->
  if window.isDarkTheme
    backgroundColor: 'rgba(33, 44, 33, 0.9)'
  else
    backgroundColor: 'rgba(256, 256, 256, 0.8)'

Slotitems = React.createClass
  render: ->
    <div className="slotitems">
    {
      {$slotitems, _slotitems} = window
      for itemId, i in @props.data
        continue if itemId == -1
        item = _slotitems[itemId]
        <div key={i} className="slotitem-container" style={display:"flex", alignItems:"center"}>
          <img key={itemId} src={join('assets', 'img', 'slotitem', "#{item.api_type[3] + 100}.png")} style={flex:"none", width:24, height:24}/>
          <span className="item-improvment" style={flex:"none"}>
            {item.api_name }
            {if item.api_level > 0 then <strong style={color: '#45A9A5'}>★+{item.api_level}</strong> else ''}
            &nbsp;&nbsp;{
              if item.api_alv? and item.api_alv >=1 and item.api_alv <= 3
                for j in [1..item.api_alv]
                  <strong key={j} style={color: '#3EAEFF'}>|</strong>
              else if item.api_alv? and item.api_alv >= 4 and item.api_alv <= 6
                for j in [1..item.api_alv - 3]
                  <strong key={j} style={color: '#F9C62F'}>\</strong>
              else if item.api_alv? and item.api_alv >= 7 and item.api_alv <= 9
                <strong key={j} style={color: '#F9C62F'}> <FontAwesome key={0} name='angle-double-right'/> </strong>
              else if item.api_alv? and item.api_alv >= 9
                <strong key={j} style={color: '#F94D2F'}>★</strong>
              else ''
            }&nbsp;&nbsp;
          </span>
          <span className="slotitem-onslot
                          #{if (item.api_type[3] >= 6 && item.api_type[3] <= 10) || (item.api_type[3] >= 21 && item.api_type[3] <= 22) || item.api_type[3] == 33 then 'show' else 'hide'}
                          #{if @props.onslot[i] < @props.maxeq[i] then 'text-warning' else ''}"
                          style={getBackdropStyle()}>
            {@props.onslot[i]}
          </span>
        </div>
    }
    {
      {$slotitems, _slotitems} = window
      if @props.dataex > 0
        item = _slotitems[@props.dataex]
        <div key={i} className="slotitem-container">
          <OverlayTrigger placement='left' overlay={
            <Tooltip>
              {item.api_name}
            </Tooltip>
          }>
            <img key={itemId} src={path.join('assets', 'img', 'slotitem', "#{item.api_type[3] + 100}.png")} />
          </OverlayTrigger>
          <span className="slotitem-onslot
                          #{if (item.api_type[3] >= 6 && item.api_type[3] <= 10) || (item.api_type[3] >= 21 && item.api_type[3] <= 22) || item.api_type[3] == 33 then 'show' else 'hide'}
                          #{if @props.onslot[i] < @props.maxeq[i] then 'text-warning' else ''}"
                          style={getBackgroundStyle()}>
            {@props.onslot[i]}
          </span>
        </div>
    }
    </div>

# Tyku
# 制空値 = [(艦載機の対空値) × √(搭載数)] の総計
getTyku = (deck) ->
  {$ships, $slotitems, _ships, _slotitems} = window
  totalTyku = 0
  for shipId in deck.api_ship
    continue if shipId == -1
    ship = _ships[shipId]
    for itemId, slotId in ship.api_slot
      continue if itemId == -1
      item = _slotitems[itemId]
      if item.api_type[3] in [6, 7, 8]
        totalTyku += Math.floor(Math.sqrt(ship.api_onslot[slotId]) * item.api_tyku)
      else if item.api_type[3] == 10 && item.api_type[2] == 11
        totalTyku += Math.floor(Math.sqrt(ship.api_onslot[slotId]) * item.api_tyku)
  totalTyku

getDeckMessage = (deck) ->
  {$ships, $slotitems, _ships} = window
  totalLv = totalShip = 0
  for shipId in deck.api_ship
    continue if shipId == -1
    ship = _ships[shipId]
    totalLv += ship.api_lv
    totalShip += 1
  avgLv = totalLv / totalShip

  totalLv: totalLv
  avgLv: parseFloat(avgLv.toFixed(0))
  tyku: getTyku(deck)
  # saku25: getSaku25(deck)
  # saku25a: getSaku25a(deck)

TopAlert = React.createClass
  messages: ['没有舰队信息']
  maxCountdown: 0
  getInitialState: ->
    inMission: false
  getState: ->
    if @state.inMission
      return '远征'
    else
      return '回复'
  render: ->
    <div style={display: "flex", justifyContent: "space-around", padding:5}>
      <span style={flex: "none"}>总 Lv.{@messages.totalLv}</span>
      <span style={flex: "none"}>均 Lv.{@messages.avgLv}</span>
      <span style={flex: "none"}>制空:&nbsp;{@messages.tyku}</span>
      <span style={flex: "none"}>{@getState()}:&nbsp;<span id={"deck-condition-countdown-#{@props.deckIndex}"}>{resolveTime @maxCountdown}</span></span>
    </div>

repairTimer =
  remain: 0
  total: 0
missionTimer =
  remain: 0
  total: 0
condTimer =
  remain: 0
  total: 0

PaneBody = React.createClass
  condDynamicUpdateFlag: false
  getInitialState: ->
    cond: [0, 0, 0, 0, 0, 0]
    label: [[false, false, false, false, false, false],
            [false, false, false, false, false, false],
            [false, false, false, false, false, false],
            [false, false, false, false, false, false],
            [false, false, false, false, false, false],
            [false, false, false, false, false, false]]
    retreat: [false, false, false, false, false, false]
    repairTimer: Object.clone(repairTimer)
    missionTimer: Object.clone(missionTimer)
    condTimer: Object.clone(condTimer)
  onCondChange: (cond) ->
    condDynamicUpdateFlag = true
    @setState
      cond: cond
  getCondRemain: (deck) ->
    {$ships, $slotitems, _ships} = window
    total = [0, 0, 0, 0, 0, 0]
    remain = [0, 0, 0, 0, 0, 0]
    maxflag = 0
    t = new Date()
    for shipId, i in deck.api_ship
      ship = _ships[shipId]
      if shipId == -1 or ship.api_cond >= 49
        continue
      if @props.condStartTime[shipId]?
        complete = Math.ceil((49 - ship.api_cond) / 3) * 3 * 60 * 1000 + @props.condStartTime[shipId]
        total[i] = complete - @props.condStartTime[shipId]
        remain[i] = complete - Date.now()
    # returns milli second
    maxflag = remain.indexOf(Math.max.apply(Math, remain))
    {
      totalmax: total[maxflag]
      remainmax: remain[maxflag]
    }
  updateTimers: (ndocks) ->
    {missionTimer, repairTimer, condTimer} = @state
    # set repair timer
    repairTimer.total = 0
    repairTimer.remain = 0
    for ndock, i in ndocks
      if ndock.api_complete_time > 0 and ndock.api_ship_id in @props.deck.api_ship
        t = new Date()
        repairTimer.total = ndock.api_complete_time - t
        repairTimer.remain = ndock.api_complete_time - t
    # set cond timer
    timer = @getCondRemain(@props.deck)
    condTimer.total = timer.totalmax
    condTimer.remain = timer.remainmax
    # set mission timer
    if @props.deckIndex != 0
      {$missions} = window
      complete = @props.deck.api_mission[2]
      mId = @props.deck.api_mission[1]
      if mId == 0
        missionTimer.total = 0
        missionTimer.remain = 0
      else
        t = new Date()
        missionTimer.total = $missions[mId].api_time * 60 * 1000
        missionTimer.remain = complete - t
    [missionTimer, repairTimer, condTimer]
  updateLabels: ->
    # refresh label
    {label} = @state
    for shipId, j in @props.deck.api_ship
      continue if shipId == -1
      ship = _ships[shipId]
      status = getStatusArray shipId
      status[0] = @state.retreat[j]
      label[j] = status
    label
  handleResponse: (e) ->
    {method, path, body, postBody} = e.detail
    {retreat, missionTimer, repairTimer, condTimer, label} = @state
    updateflag = false
    ndocks = []
    switch path
      when '/kcsapi/api_port/port'
        retreat = [false, false, false, false, false, false]
        updateflag = true
        ndocks = Object.clone(body.api_ndock)
      when '/kcsapi/api_req_hensei/change'
        updateflag = true
      when '/kcsapi/api_req_mission/start'
        # postBody.api_deck_id is a string starting from 1
        deckIndex = parseInt postBody.api_deck_id
        if @props.deckIndex != 0
          t = new Date()
          total = body.api_complatetime - t
          missionTimer.total = total
          missionTimer.remain = total
          updateflag = true
      when "/kcsapi/api_req_combined_battle/battleresult"
        if body.api_escape_flag
          id = body.api_escape.api_escape_idx
          if id > 6 and @props.deckIndex == 1
            id -= 6
            tow = body.api_escape.api_tow_idx - 6
            retreat[tow - 1] = true
          retreat[id - 1] = true
      when '/kcsapi/api_req_combined_battle/goback_port'
        if not body.api_result
          retreat = [false, false, false, false, false, false]
      when '/kcsapi/api_req_nyukyo/start'
        shipId = parseInt postBody.api_ship_id
        if shipId in @props.deck.api_ship
          i = @props.deck.api_ship.indexOf shipId
          status = getStatusArray shipId
          label[i] = status
          updateflag = true
    if updateflag
      timers = @updateTimers(ndocks)
      missionTimer = timers[0]
      repairTimer = timers[1]
      condTimer = timers[2]
      label = @updateLabels()
      @setState
        condTimer: condTimer
        repairTimer: repairTimer
        missionTimer: missionTimer
        retreat: retreat
        label: label
  componentDidMount: ->
    window.addEventListener 'game.response', @handleResponse
    label = @updateLabels()
    @setState
      label: label
  componentWillUnmount: ->
    window.removeEventListener 'game.response', @handleResponse
  shouldComponentUpdate: (nextProps, nextState) ->
    nextProps.activeDeck is @props.deckIndex
  componentWillReceiveProps: (nextProps) ->
    if @condDynamicUpdateFlag
      @condDynamicUpdateFlag = not @condDynamicUpdateFlag
    else
      cond = [0, 0, 0, 0, 0, 0]
      for shipId, j in nextProps.deck.api_ship
        if shipId == -1
          cond[j] = 49
          continue
        ship = _ships[shipId]
        cond[j] = ship.api_cond
      @setState
        cond: cond
  componentWillMount: ->
    cond = [0, 0, 0, 0, 0, 0]
    for shipId, j in @props.deck.api_ship
      if shipId == -1
        cond[j] = 49
        continue
      ship = _ships[shipId]
      cond[j] = ship.api_cond
    @setState
      cond: cond
  render: ->
    <div>
      <div style={display:"flex", justifyContent:"space-between", margin:"5px 0"}>
        <OverlayTrigger placement="top" overlay={
          <Tooltip>
            <div>
              <TopAlert
                updateCond={@onCondChange}
                messages={@props.messages}
                deckIndex={@props.deckIndex}
                deckName={@props.deckName}
              />
            </div>
          </Tooltip>
          }>
          <span className="ship-more" style={flex:"none"}><FontAwesome key={0} name='clock-o' /></span>
        </OverlayTrigger>
        <RecoveryBar style={flex:"auto"}
          deck={@props.deck}
          deckIndex = {@props.deckIndex}
          repairTimer = {@state.repairTimer}
          missionTimer = {@state.missionTimer}
          condTimer = {@state.condTimer}
          />
      </div>
      <div className="ship-details">
      {
        {$ships, $shipTypes, _ships} = window
        for shipId, j in @props.deck.api_ship
          continue if shipId == -1
          ship = _ships[shipId]
          shipInfo = $ships[ship.api_ship_id]
          shipType = $shipTypes[shipInfo.api_stype].api_name
          [
            <div className="ship-tile">
              <div className="status-label">
                <status-labelMini label={@state.label[j]}/>
              </div>
              <div className="ship-item" style={getStatusStyle @state.label[j]}>
                <OverlayTrigger placement="top" overlay={
                  <Tooltip>
                    <div>
                      <Slotitems className="ship-slot" data={ship.api_slot} onslot={ship.api_onslot} maxeq={ship.api_maxeq} dataex={ship.api_slot_ex} />
                    </div>
                  </Tooltip>
                }>
                  <div className="ship-info" >
                    <span className="ship-lv">
                      Lv. {ship.api_lv}
                    </span>
                    <span className="ship-name">
                      {shipInfo.api_name}
                    </span>
                    <span className="ship-cond" style={color:getCondStyle ship.api_cond}>
                      ★{ship.api_cond}
                    </span>
                  </div>
                </OverlayTrigger>
                <div className="flex-row" style={width:"100%", marginTop:5}>
                  <span className="ship-hp">
                    <span className="ship-hp-text" style={flex: "none", display: "flex"}>
                      {ship.api_nowhp} / {ship.api_maxhp}
                    </span>
                    <OverlayTrigger show = {ship.api_ndock_time} placement='bottom' overlay={<Tooltip>入渠时间：{resolveTime ship.api_ndock_time / 1000}</Tooltip>}>
                      <ProgressBar style={flex: "auto"} bsStyle={getHpStyle ship.api_nowhp / ship.api_maxhp * 100} now={ship.api_nowhp / ship.api_maxhp * 100} />
                    </OverlayTrigger>
                    <span className="ship-fuelbullet" style={flex: "none"}>
                      <ProgressBar bsStyle={getMaterialStyle ship.api_fuel / shipInfo.api_fuel_max * 100}
                                   now={ship.api_fuel / shipInfo.api_fuel_max * 100} />
                    </span>
                    <span className="ship-fuelbullet" style={flex: "none"}>
                      <ProgressBar bsStyle={getMaterialStyle ship.api_bull / shipInfo.api_bull_max * 100}
                                   now={ship.api_bull / shipInfo.api_bull_max * 100} />
                    </span>
                  </span>
                </div>

              </div>
            </div>
          ]
      }
      </div>
    </div>

module.exports =
  name: 'miniship'
  priority: 100000.1
  displayName: <span><FontAwesome key={0} name='bars' /> Mini舰队</span>
  description: '舰队展示页面，展示舰队详情信息'
  reactClass: React.createClass
    getInitialState: ->
      names: ['I', 'II', 'III', 'IV']
      states: [-1, -1, -1, -1]
      decks: []
      activeDeck: 0
      dataVersion: 0
    showDataVersion: 0
    condStartTime: {}
    shouldComponentUpdate: (nextProps, nextState)->
      # if ship-pane is visibile and dataVersion is changed, this pane should update!
      if nextProps.selectedKey is @props.index and nextState.dataVersion isnt @showDataVersion
        @showDataVersion = nextState.dataVersion
        return true
      if @state.decks.length is 0 and nextState.decks.length isnt 0
        return true
      false
    handleClick: (idx) ->
      if idx isnt @state.activeDeck
        @setState
          activeDeck: idx
          dataVersion: @state.dataVersion + 1
    handleResponse: (e) ->
      {method, path, body, postBody} = e.detail
      {names} = @state
      flag = true
      switch path
        when '/kcsapi/api_port/port'
          # names = body.api_deck_port.map (e) -> e.api_name
          inBattle = [false, false, false, false]
          for shipId of _ships
            t = new Date().getTime()
            if @condStartTime[shipId]?
              if _ships[shipId].api_cond >= 49
                @condStartTime[shipId] = 0
                continue
              if @condStartTime[shipId] > 0
                step = (t - @condStartTime[shipId]) / (3 * 60 * 1000)
                if step >= 1
                  # forward time
                  @condStartTime[shipId] += 3 * 60 * 1000 * Math.floor(step)
              else
                @condStartTime[shipId] = t
            else
              @condStartTime[shipId] = t
            # Math.ceil((49 - _ships[shipId].api_cond) / 3) * 3 * 60 * 1000 + t.getTime()
        when '/kcsapi/api_req_hensei/change', '/kcsapi/api_req_hokyu/charge', '/kcsapi/api_get_member/deck', '/kcsapi/api_get_member/ship_deck', '/kcsapi/api_get_member/ship2', '/kcsapi/api_get_member/ship3',  '/kcsapi/api_req_kaisou/powerup', '/kcsapi/api_req_nyukyo/start', '/kcsapi/api_req_nyukyo/speedchange'
          true
        when '/kcsapi/api_req_kousyou/destroyship'
          shipId = parseInt postBody.api_ship_id
          delete @condStartTime[shipId]
          true
        when '/kcsapi/api_req_map/start'
          deckId = parseInt(postBody.api_deck_id) - 1
          inBattle[deckId] = true
          {decks, states} = @state
          {_ships} = window
          deck = decks[deckId]
          # for shipId in deck.api_ship
          #   continue if shipId == -1
          #   ship = _ships[shipId]
          #   if ship.api_nowhp / ship.api_maxhp < 0.250001
          #     toggleModal '出击注意！', "Lv. #{ship.api_lv} - #{ship.api_name} 大破，可能会被击沉！"
        # when '/kcsapi/api_req_map/next'
        #   {decks, states} = @state
        #   {_ships} = window
        #   for deck, i in decks
        #     continue if states[i] != 5
        #     for shipId in deck.api_ship
        #       continue if shipId == -1
        #       ship = _ships[shipId]
        #       if ship.api_nowhp / ship.api_maxhp < 0.250001
        #         toggleModal '进击注意！', "Lv. #{ship.api_lv} - #{ship.api_name} 大破，可能会被击沉！"
        else
          flag = false
      return unless flag
      decks = window._decks
      states = decks.map (deck) ->
        getDeckState deck
      @setState
        names: names
        decks: decks
        states: states
        dataVersion: @state.dataVersion + 1
    componentDidMount: ->
      window.addEventListener 'game.response', @handleResponse
    componentWillUnmount: ->
      window.removeEventListener 'game.response', @handleResponse
      @interval = clearInterval @interval if @interval?
    render: ->
      <Panel bsStyle="default" >
        <link rel="stylesheet" href={join(relative(ROOT, __dirname),'..', 'assets', 'miniship.css')} />
        <ButtonGroup>
        {
          for i in [0..3]
            <Button key={i} bsSize="small"
                            bsStyle={getStyle @state.states[i]}
                            onClick={@handleClick.bind(this, i)}
                            className={if @state.activeDeck == i then 'active' else ''}>
              {@state.names[i]}
            </Button>
        }
        </ButtonGroup>
        {
          for deck, i in @state.decks
            <div className="ship-deck" className={if @state.activeDeck is i then 'show' else 'hidden'} key={i}>
              <PaneBody
                condStartTime={@condStartTime}
                key={i}
                deckIndex={i}
                deck={@state.decks[i]}
                activeDeck={@state.activeDeck}
                deckName={@state.names[i]}
              />
            </div>
        }
      </Panel>
